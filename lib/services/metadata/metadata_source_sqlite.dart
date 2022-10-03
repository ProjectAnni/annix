import 'dart:convert';
import 'dart:io';

import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class SqliteMetadataSource extends MetadataSource {
  String dbFolderPath;
  late Database database;

  SqliteMetadataSource(this.dbFolderPath);

  @override
  Future<void> prepare() async {
    database =
        await openDatabase(p.join(dbFolderPath, 'repo.db'), readOnly: true);
  }

  @override
  Future<bool> canUpdate() async {
    return false;
  }

  Future<Album?> _getAlbum(String albumId) async {
    final albumUuid = albumId.replaceAll('-', '').toUpperCase();
    final List<Map<String, Object?>> discs = await database.rawQuery(
        'SELECT * FROM repo_disc WHERE hex(album_id) = ? ORDER BY disc_id',
        [albumUuid]);

    final List<Disc> albumDiscs = await Future.wait(discs.map((disc) async {
      final int discId = disc['disc_id'] as int;
      final String discTitle = disc['title'] as String;
      final String discArtist = disc['artist'] as String;
      final String discCatalog = disc['catalog'] as String;
      final TrackType discType =
          TrackType.fromString(disc['disc_type'] as String);

      final List<Map<String, Object?>> tracks = await database.rawQuery(
          'SELECT title, artist, track_type FROM repo_track WHERE hex(album_id) = ? AND disc_id = ? ORDER BY disc_id',
          [albumUuid, discId]);
      final List<Track> discTracks = tracks.map((track) {
        final String trackTitle = track['title'] as String;
        final String trackArtist = track['artist'] as String;
        final TrackType trackType =
            TrackType.fromString(track['track_type'] as String);
        return Track(title: trackTitle, artist: trackArtist, type: trackType);
      }).toList();

      return Disc(
        title: discTitle,
        catalog: discCatalog,
        artist: discArtist,
        type: discType,
        tracks: discTracks,
      );
    }));
    final List<Map<String, Object?>> album = await database.rawQuery(
        'SELECT * FROM repo_album WHERE hex(album_id) = ?', [albumUuid]);
    if (album.isNotEmpty) {
      final String title = album[0]['title'] as String;
      final String? edition = album[0]['edition'] as String?;
      final String catalog = album[0]['catalog'] as String;
      final String artist = album[0]['artist'] as String;
      final String releaseDate = album[0]['release_date'] as String;
      final TrackType albumType =
          TrackType.fromString(album[0]['album_type'] as String);

      return Album(
        albumId: albumId,
        title: title,
        edition: edition,
        artist: artist,
        catalog: catalog,
        date: ReleaseDate.fromDynamic(releaseDate),
        type: albumType,
        discs: albumDiscs,
      );
    } else {
      return null;
    }
  }

  @override
  Future<Map<String, Album>> getAlbums(List<String> albums) async {
    return Map.fromEntries(
        (await Future.wait(albums.map((albumId) => _getAlbum(albumId))))
            .where((e) => e != null)
            .map((e) => MapEntry(e!.albumId, e)));
  }

  @override
  Future<Set<String>> getAlbumsByTag(String tag) async {
    final albums = await database.rawQuery('''
WITH RECURSIVE recursive_tags(tag_id) AS (
  SELECT tag_id FROM repo_tag WHERE name = ?

  UNION ALL

  SELECT rl.tag_id FROM repo_tag_relation rl, recursive_tags rt WHERE rl.parent_id = rt.tag_id
)

SELECT lower(hex(album_id)) album_id FROM repo_album WHERE album_id IN (
    SELECT DISTINCT album_id FROM repo_tag_detail WHERE tag_id IN (
        SELECT * FROM recursive_tags
    )
)
''', [tag]);
    return albums
        .map((e) => e['album_id'] as String)
        .map((str) =>
            '${str.substring(0, 8)}-${str.substring(8, 12)}-${str.substring(12, 16)}-${str.substring(16, 20)}-${str.substring(20, 32)}')
        .toSet();
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    final tags = await database.rawQuery(
      'SELECT tag_id, name, tag_type, children FROM repo_tag LEFT JOIN (SELECT parent_id, group_concat(tag_id) children FROM repo_tag_relation GROUP BY parent_id) ON repo_tag.tag_id = parent_id',
    );
    final tagsMap = Map.fromEntries(tags.map(
      (e) => MapEntry(
        e['tag_id'] as int,
        TagEntry(
          name: e['name'] as String,
          type: TagType.fromString(e['tag_type'] as String),
          children: [(e['children'] as String?) ?? ''],
        ),
      ),
    ));
    tagsMap.forEach((tagId, tag) {
      final children = tag.children.removeLast();
      if (children.isNotEmpty) {
        tag.children.addAll(
          children
              .split(',')
              .map((e) => int.parse(e))
              .map((e) => tagsMap[e]!.name),
        );
      }
    });

    return Map.fromEntries(tagsMap.values.map((e) => MapEntry(e.name, e)));
  }

  Future<RepoDatabaseDescription> getDescription() async {
    final data = await File(p.join(dbFolderPath, 'repo.json')).readAsString();
    return RepoDatabaseDescription.fromJson(jsonDecode(data));
  }
}
