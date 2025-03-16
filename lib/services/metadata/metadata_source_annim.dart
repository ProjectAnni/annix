import 'dart:convert';

import 'package:annix/native/api/simple.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:uuid/uuid.dart';

// TODO: cache
class AnnimMetadataSource extends MetadataSource with CachedMetadataStore {
  late Annim _client;

  @override
  Future<void> prepare() async {
    _client = await Annim.newInstance(endpoint: 'https://starry.anni.rs');
  }

  @override
  Future<Map<String, Album>> getAlbumsDetail(final List<String> albums) async {
    final ids = albums.map((e) => UuidValue.fromString(e)).toList();
    final result = await _client.getAlbums(ids: ids);
    return Map.fromEntries(result.map((e) {
      final album = Album.fromJson(jsonDecode(e));
      return MapEntry(album.albumId, album);
    }));
  }

  @override
  Future<Set<String>> getAlbumsByTag(final String tag) async {
    return {};
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    return {};
  }
}
