import 'package:annix/services/metadata/metadata_types.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/utils/store.dart';
import 'package:flutter/foundation.dart';

/// MetadataSource is the source of local metadata need by the whole application.
///
/// It can be folder with structure defined in [Anni Metadata Repository][metadata-repository], or pre-compiled sqlite database file.
///
/// [metadata-repository]: https://book.anni.rs/02.metadata-repository/00.readme.html
abstract class MetadataSource {
  /// Prepare for metadata source
  Future<void> prepare();

  /// Update metadata source by calling [doUpdate]
  ///
  /// [doUpdate] might be called when caller [force] to update,
  /// or when [canUpdate] returns true
  ///
  /// This function returns whether an update is done actually.
  Future<bool> update({force = false}) async {
    if (force || await canUpdate()) {
      bool updated = await doUpdate();
      if (updated) {
        // metadata repository updated, invalidate cache
        await _albumStore.clear();
      }
      return updated;
    }
    return false;
  }

  /// Controls whether to update metadata when not forced
  Future<bool> canUpdate() async {
    return false;
  }

  /// The actual update part. Override this function with actual implementation.
  Future<bool> doUpdate() async {
    return false;
  }

  /// Whether a metadata source needs to be cached
  bool get needPersist;

  /// Get detail of multiple albums
  Future<Map<String, Album>> getAlbumsDetail(List<String> albums);

  /// Get info of all tags
  Future<Map<String, TagEntry>> getTags();

  /// Get album id by tag name
  Future<List<String>> getAlbumsByTag(String tag);

  /// Private album object cache for album object reading
  static final _albumStore = AnnixStore().category('album');

  /// Get album information
  Future<Album?> getAlbum({required String albumId}) async {
    if (!await _albumStore.contains(albumId)) {
      // album not in cache, load it from source
      final albums = await getAlbumsDetail([albumId]);
      if (albums.isEmpty) {
        // album not found
        return null;
      }

      final album = albums[albumId]!;
      if (needPersist) {
        // album need persist
        await persist(album);
      }
      return album;
    }
    final data = await _albumStore.get(albumId);
    return Album.fromJson(data!);
  }

  Future<Map<String, Album>> getAlbums(List<String> albums) async {
    // dedup album list
    final albumToGet = albums.toSet();
    final result = <String, Album>{};
    final toFetch = <String>[];

    for (final albumId in albumToGet) {
      final cache = await _albumStore.get(albumId);
      if (cache != null) {
        result[albumId] = Album.fromJson(cache);
      } else {
        toFetch.add(albumId);
      }
    }

    final got = await getAlbumsDetail(toFetch);
    if (needPersist) {
      for (final albumId in toFetch) {
        final album = got[albumId];
        if (album != null) {
          await persist(album);
        }
      }
    }
    result.addAll(got);
    return result;
  }

  /// Get track information
  Future<Track?> getTrack({
    required String albumId,
    required int discId,
    required int trackId,
  }) async {
    Album? album = await getAlbum(albumId: albumId);
    return album?.discs[discId - 1].tracks[trackId - 1];
  }

  @protected
  Future<void> persist(Album album) async {
    await _albumStore.set(album.albumId, album.toJson());
  }
}
