import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:annix/services/metadata/metadata_source_anniv.dart';

class MetadataService {
  final List<MetadataSource> sources = [
    // default
    AnnivMetadataSource(),
  ];

  /// Update metadata source by calling [doUpdate]
  ///
  /// [doUpdate] might be called when caller [force] to update,
  /// or when [canUpdate] returns true
  ///
  /// This function returns whether an update is done actually.
  Future<bool> update() async {
    for (final source in sources) {
      if (await source.canUpdate()) {
        return await source.doUpdate();
      }
    }
    return false;
  }

  /// Get album information
  Future<Album?> getAlbum({required String albumId}) async {
    for (final source in sources) {
      final album = await source.getAlbums([albumId]);
      if (album.isNotEmpty) {
        return album.values.first;
      }
    }
    return null;
  }

  Future<Map<String, Album>> getAlbums(List<String> albums) async {
    final albumToGet = albums.toSet().toList();
    final result = <String, Album>{};

    for (final source in sources) {
      final got = await source.getAlbums(albumToGet);
      result.addAll(got);

      if (result.length == albums.length) {
        return result;
      } else {
        albumToGet.removeWhere((albumId) => result.containsKey(albumId));
      }
    }

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

  /// Get info of all tags
  Future<Map<String, TagEntry>> getTags() async {
    for (final source in sources) {
      final tags = await source.getTags();
      if (tags.isNotEmpty) {
        return tags;
      }
    }
    return {};
  }

  /// Get album id by tag name
  Future<List<String>> getAlbumsByTag(String tag) async {
    for (final source in sources) {
      final albums = await source.getAlbumsByTag(tag);
      if (albums.isNotEmpty) {
        return albums;
      }
    }
    return [];
  }
}
