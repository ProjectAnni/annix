import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/utils/store.dart';

/// MetadataSource is the source of local metadata need by the whole application.
///
/// It can be folder with structure defined in [Anni Metadata Repository][metadata-repository], or pre-compiled sqlite database file.
///
/// [metadata-repository]: https://book.anni.rs/02.metadata-repository/00.readme.html
abstract class MetadataSource {
  /// Prepare for metadata source
  Future<void> prepare();

  /// Controls whether to update metadata when not forced
  Future<bool> canUpdate() async {
    return false;
  }

  /// The actual update part. Override this function with actual implementation.
  Future<bool> doUpdate() async {
    return false;
  }

  /// Get detail of multiple albums
  Future<Map<String, Album>> getAlbums(List<String> albums);

  /// Get info of all tags
  Future<Map<String, TagEntry>> getTags();

  /// Get album id by tag name
  Future<List<String>> getAlbumsByTag(String tag);
}

mixin CachedMetadataStore {
  /// Private album object cache for album object reading
  static final _albumStore = AnnixStore().category('album');
  static final _albumCache = <String, Album>{};

  static Album? getFromCache(String albumId) {
    return _albumCache[albumId];
  }

  Future<void> persist(Album album) async {
    await _albumStore.set(album.albumId, album.toJson());
  }

  Future<Map<String, Album>> getAlbums(List<String> albums) async {
    // deduplicate album list
    final albumToGet = albums.toSet();
    final result = <String, Album>{};
    final toFetch = <String>[];

    for (final albumId in albumToGet) {
      final inCache = _albumCache[albumId];
      if (inCache != null) {
        result[albumId] = inCache;
        continue;
      }

      final cache = await _albumStore.get(albumId);
      if (cache != null) {
        final album = Album.fromJson(cache);
        result[albumId] = album;
        _albumCache[albumId] = album;
      } else {
        toFetch.add(albumId);
      }
    }

    final got = await getAlbumsDetail(toFetch);
    for (final albumId in toFetch) {
      final album = got[albumId];
      if (album != null) {
        await persist(album);
        _albumCache[albumId] = album;
      }
    }
    result.addAll(got);
    return result;
  }

  Future<Map<String, Album>> getAlbumsDetail(List<String> albums);
}
