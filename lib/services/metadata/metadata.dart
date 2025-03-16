import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:flutter/material.dart';

class MetadataService {
  final List<MetadataSource> sources = [];
  // ignore: invalid_use_of_visible_for_testing_member
  final WeakMap<String, Album?> _albumCache = WeakMap();

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

  Set<String> _getAlbumDebounceList = {};
  Future<Map<String, Album>>? _getAlbumDebouncer;

  /// Get album information
  Future<Album?> getAlbum({required final String albumId}) async {
    if (_albumCache[albumId] != null) {
      return _albumCache[albumId];
    }

    _getAlbumDebounceList.add(albumId);
    _getAlbumDebouncer ??=
        Future.delayed(const Duration(milliseconds: 200)).then((final _) async {
      final albumsToGet = _getAlbumDebounceList;
      _getAlbumDebounceList = {};
      _getAlbumDebouncer = null;

      final Map<String, Album> result = {};
      for (final source in sources) {
        final album = await source.getAlbums(albumsToGet.toList());
        result.addAll(album);
        if (result.length == albumsToGet.length) {
          break;
        }
      }

      return result;
    });
    final albums = await _getAlbumDebouncer!;
    final album = albums[albumId];
    _albumCache[albumId] = album;
    return album;
  }

  Future<Map<String, Album>> getAlbums(final List<String> albums) async {
    final albumToGet = albums.toSet().toList();
    final result = <String, Album>{};

    for (final source in sources) {
      final got = await source.getAlbums(albumToGet);
      result.addAll(got);

      if (result.length == albums.length) {
        return result;
      } else {
        albumToGet.removeWhere((final albumId) => result.containsKey(albumId));
      }
    }

    return result;
  }

  /// Get track information
  Future<Track?> getTrack(final TrackIdentifier id) async {
    final album = await getAlbum(albumId: id.albumId);
    return album?.discs[id.discId - 1].tracks[id.trackId - 1];
  }

  Future<Map<TrackIdentifier, TrackInfoWithAlbum?>> getTracks(
      final List<TrackIdentifier> ids) async {
    final albumIds = ids.map((final id) => id.albumId).toSet().toList();
    final albums = await getAlbums(albumIds);

    final result = <TrackIdentifier, TrackInfoWithAlbum?>{};
    for (final id in ids) {
      final album = albums[id.albumId];
      if (album != null) {
        final track = album.discs[id.discId - 1].tracks[id.trackId - 1];
        result[id] = TrackInfoWithAlbum(
          id: id,
          title: track.title,
          artist: track.artist,
          albumTitle: album.title,
          type: track.type,
        );
      }
    }
    return result;
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
  Future<Set<String>> getAlbumsByTag(final String tag) async {
    for (final source in sources) {
      final albums = await source.getAlbumsByTag(tag);
      if (albums.isNotEmpty) {
        return albums;
      }
    }
    return {};
  }
}
