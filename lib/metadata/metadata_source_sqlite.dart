import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:sqflite/sqflite.dart';

class SqliteMetadataSource extends MetadataSource {
  String dbPath;
  late Database database;

  SqliteMetadataSource(this.dbPath);

  @override
  Future<void> prepare() async {
    database = await openDatabase(dbPath, readOnly: true);
  }

  @override
  Future<bool> canUpdate() async {
    return false;
  }

  Future<Album?> getAlbumDetail(String albumId) async {
    var albumUuid = albumId.replaceAll('-', '').toUpperCase();
    List<Map<String, Object?>> discs = await database.rawQuery(
        "SELECT * FROM repo_disc WHERE hex(album_id) = ? ORDER BY disc_id",
        [albumUuid]);

    List<Disc> albumDiscs = await Future.wait(discs.map((disc) async {
      int discId = disc['disc_id'] as int;
      String discTitle = disc['title'] as String;
      String discArtist = disc['artist'] as String;
      String discCatalog = disc['catalog'] as String;
      TrackType discType =
          TrackTypeExtension.fromString(disc['disc_type'] as String);

      List<Map<String, Object?>> tracks = await database.rawQuery(
          "SELECT title, artist, track_type FROM repo_track WHERE hex(album_id) = ? AND disc_id = ? ORDER BY disc_id",
          [albumUuid, discId]);
      List<Track> discTracks = tracks.map((track) {
        String trackTitle = track['title'] as String;
        String trackArtist = track['artist'] as String;
        TrackType trackType =
            TrackTypeExtension.fromString(track['track_type'] as String);
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
    List<Map<String, Object?>> album = await database.rawQuery(
        "SELECT * FROM repo_album WHERE hex(album_id) = ?", [albumUuid]);
    if (album.isNotEmpty) {
      String title = album[0]['title'] as String;
      String? edition = album[0]['edition'] as String?;
      String catalog = album[0]['catalog'] as String;
      String artist = album[0]['artist'] as String;
      String releaseDate = album[0]['release_date'] as String;
      TrackType albumType =
          TrackTypeExtension.fromString(album[0]['album_type'] as String);

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

  Future<Map<String, Album>> getAlbumsDetail(List<String> albums) async {
    return Map.fromEntries(
        (await Future.wait(albums.map((albumId) => getAlbumDetail(albumId))))
            .where((e) => e != null)
            .map((e) => MapEntry(e!.albumId, e)));
  }

  @override
  bool get needPersist => false;

  @override
  Future<List<String>> getAlbumsByTag(String tag) async {
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
            "${str.substring(0, 8)}-${str.substring(8, 12)}-${str.substring(12, 16)}-${str.substring(16, 20)}-${str.substring(20, 32)}")
        .toList();
  }
}
