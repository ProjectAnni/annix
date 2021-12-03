import 'package:annix/metadata/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:stash/stash_api.dart';
import 'package:stash_memory/stash_memory.dart';

/// MetadataSource is the source of local metadata need by the whole application.
///
/// It can be folder with structure defined in [Anni Metadata Repository][metadata-repository], or pre-compiled sqlite database file.
///
/// [metadata-repository]: https://book.anni.rs/02.metadata-repository/00.readme.html
abstract class BaseMetadataSource {
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
        await _albumCache.clear();
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

  /// Private album object cache for album object reading
  static final _albumCache = Global.cacheStore.cache(
    cacheName: 'album',
    maxEntries: 64,
    evictionPolicy: LruEvictionPolicy(),
  );

  /// Get album information
  ///
  /// DO NOT OVERRIDE THIS METHOD
  Future<Album?> getAlbum({required String catalog}) async {
    if (!await _albumCache.containsKey(catalog)) {
      // album not in cache, load it from source
      Album? album = await getAlbumDetail(catalog: catalog);
      if (album == null) {
        // album not found
        return null;
      } else {
        await _albumCache.put(catalog, album);
      }
    }
    return await _albumCache.get(catalog);
  }

  /// Actual method to get album detail from metadata source
  /// Override this function to grant ability to get album detail
  ///
  /// Return null if album is not found
  Future<Album?> getAlbumDetail({required String catalog});

  /// Get track information
  ///
  /// DO NOT OVERRIDE THIS METHOD
  Future<Track?> getTrack(
      {required String catalog, discIndex = 0, required int trackIndex}) async {
    Album? album = await getAlbum(catalog: catalog);
    return album?.discs[discIndex].tracks[trackIndex];
  }
}

enum MetadataSoruceType {
  /// Remote git repository
  GitRemote,

  /// Local git repository
  GitLocal,

  /// Downloadable remote zip file
  Zip,

  /// Prebuilt Database file
  Database,

  /// Local folder
  Folder,
}
