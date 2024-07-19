import 'dart:convert';
import 'dart:io';

import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:annix/native/api/simple.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SqliteMetadataSource extends MetadataSource {
  String dbFolderPath;
  late LocalDb database;

  SqliteMetadataSource(this.dbFolderPath);

  @override
  Future<void> prepare() async {
    database = await LocalDb.newInstance(path: p.join(dbFolderPath, 'repo.db'));
  }

  @override
  Future<bool> canUpdate() async {
    return false;
  }

  Future<Album?> _getAlbum(final String albumId) async {
    final album = await database.getAlbum(albumId: UuidValue.raw(albumId));
    if (album == null) {
      return null;
    } else {
      return Album.fromJson(jsonDecode(album));
    }
  }

  @override
  Future<Map<String, Album>> getAlbums(final List<String> albums) async {
    return Map.fromEntries(
        (await Future.wait(albums.map((final albumId) => _getAlbum(albumId))))
            .where((final e) => e != null)
            .map((final e) => MapEntry(e!.albumId, e)));
  }

  @override
  Future<Set<String>> getAlbumsByTag(final String tag) async {
    final albums = await database.getAlbumsByTag(tag: tag, recursive: false);
    return albums.map((final e) => e.toString()).toSet();
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    final tags = await database.getTags();
    return Map.fromEntries(
      tags.map((final t) {
        final pos = t.name.indexOf(':');
        final type = t.name.substring(0, pos);
        final name = t.name.substring(pos + 1);
        return MapEntry(
          t.name,
          TagEntry(
            name: name,
            type: TagType.fromString(type),
            children: t.children,
          ),
        );
      }),
    );
  }

  Future<RepoDatabaseDescription> getDescription() async {
    final data = await File(p.join(dbFolderPath, 'repo.json')).readAsString();
    return RepoDatabaseDescription.fromJson(jsonDecode(data));
  }
}
