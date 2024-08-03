import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/annil/cover.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef DownloadTaskCallback = Future<DownloadTask?> Function(Ref ref);

class AudioCancelledError extends Error {}

class AnnilAudioSource {
  final PreferQuality? quality;
  final TrackInfoWithAlbum track;

  final DownloadState downloadProgress =
      DownloadState(const DownloadProgress(current: 0));

  bool isCanceled = false;
  Future<void>? _preloadFuture;
  DownloadTask? _downloadTask;

  TrackIdentifier get identifier => track.id;

  AnnilAudioSource({
    required this.track,
    this.quality,
  });

  static Future<AnnilAudioSource?> from({
    required final MetadataService metadata,
    required final TrackIdentifier id,
    final PreferQuality? quality,
  }) async {
    final track = await metadata.getTrack(id);
    if (track != null) {
      return AnnilAudioSource(
        quality: quality,
        track: TrackInfoWithAlbum.fromTrack(track),
      );
    }

    return null;
  }

  String get id => track.id.toString();

  // Future<void> setOnPlayer(final AnnixPlayer player) async {
  //   // when setOnPlayer was called, player expects to play current track
  //   // but user may change track before player is ready
  //   // so isCanceled is always false here, and may become true later
  //   isCanceled = false;

  //   final offlinePath = getAudioCachePath(track.id);
  //   final file = File(offlinePath);
  //   if (file.existsSync() && file.lengthSync() > 0) {
  //     await player.openFile(path: offlinePath);
  //   } else {
  //     // preload should be triggered before setOnPlayer
  //     assert(_preloadFuture != null);
  //     try {
  //       await _preloadFuture;
  //     } catch (e) {
  //       // set _preloadFuture to null, allowing retry
  //       _preloadFuture = null;
  //       _downloadTask = null;

  //       if (e is DownloadCancelledError) {
  //         throw AudioCancelledError();
  //       } else {
  //         rethrow;
  //       }
  //     }
  //     // check whether user has changed track for playback
  //     if (isCanceled) {
  //       throw AudioCancelledError();
  //     }
  //     await player.openFile(path: offlinePath);
  //   }
  // }

  void preload(final Ref ref) {
    if (_preloadFuture != null) {
      return;
    }

    _preloadFuture = _preload(ref);
    // preload cover without await
    _preloadCover(ref);
  }

  bool preloaded = false;

  static DownloadTaskCallback spawnDownloadTask({
    required final TrackInfoWithAlbum track,
    final PreferQuality? quality,
    final String? savePath,
  }) {
    return (final ref) async {
      final downloadQuality =
          quality ?? ref.read(settingsProvider).defaultAudioQuality.value;
      final annil = ref.read(annilProvider);
      final url =
          await annil.getAudioUrl(track: track.id, quality: downloadQuality);
      if (url == null) {
        return null;
      }

      final path = savePath ?? getAudioCachePath(track.id);
      return DownloadTask(
        category: DownloadCategory.audio,
        url: url,
        savePath: path,
        data: TrackDownloadTaskData(info: track, quality: downloadQuality),
        client: annil.client,
      );
    };
  }

  Future<void> _preload(final Ref ref) async {
    final savePath = getAudioCachePath(track.id);
    final file = File(savePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      final taskCallback = spawnDownloadTask(
        track: track,
        savePath: savePath,
      );
      final task = await taskCallback(ref);
      if (task != null) {
        await file.parent.create(recursive: true);
        ref.read(downloadManagerProvider).add(task);
        _downloadTask = task;
        _downloadTask?.addListener(_onDownloadProgress);
        final response = await task.start();

        final duration = int.parse(response.headers['x-duration-seconds']![0]);
        // +1 to avoid duration exceeding
        PlaybackService.durationMap.update((final map) {
          map[id] = Duration(seconds: duration + 1);
        });
      } else {
        throw UnsupportedError('No available annil server found');
      }
    }
    preloaded = true;
  }

  Future<void> _preloadCover(final Ref ref) async {
    final proxy = ref.read(coverProxyProvider);
    proxy.getCoverImage(albumId: track.id.albumId, discId: track.id.discId);
  }

  void cancel() {
    _downloadTask?.cancel();
    _downloadTask?.removeListener(_onDownloadProgress);
    if (downloadProgress.hasListeners) {
      downloadProgress.dispose();
    }
    isCanceled = true;
  }

  /////// Serialization ///////
  static AnnilAudioSource fromJson(final Map<String, dynamic> json) {
    return AnnilAudioSource(
      track: TrackInfoWithAlbum.fromJson(json['track']),
      quality: PreferQuality.fromString(json['quality']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track': track.toJson(),
      'quality': quality.toString(),
    };
  }

  void _onDownloadProgress() {
    final progress = _downloadTask?.progress;
    if (progress != null) {
      downloadProgress.update(progress);
    }
  }
}
