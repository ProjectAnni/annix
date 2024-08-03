import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

typedef DownloadTaskCallback = Future<DownloadTask?> Function(Ref ref);

class AudioCancelledError extends Error {}

class AnnilAudioSource {
  final PreferQuality? quality;
  final TrackInfoWithAlbum track;

  final DownloadState downloadProgress =
      DownloadState(const DownloadProgress(current: 0));

  bool isCanceled = false;
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
