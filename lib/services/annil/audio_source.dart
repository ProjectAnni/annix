import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/global.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AudioCancelledError extends Error {}

class AnnilAudioSource extends Source {
  final PreferQuality? quality;
  final TrackInfoWithAlbum track;
  ExtendedNetworkImageProvider? coverProvider;

  bool isCanceled = false;
  Future<void>? _preloadFuture;
  DownloadTask? _downloadTask;

  TrackIdentifier get identifier => track.id;

  AnnilAudioSource({
    required this.track,
    this.quality,
  });

  static Future<AnnilAudioSource?> from({
    required MetadataService metadata,
    required TrackIdentifier id,
    PreferQuality? quality,
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

  @override
  Future<void> setOnPlayer(AudioPlayer player) async {
    // when setOnPlayer was called, player expects to play current track
    // but user may change track before player is ready
    // so isCanceled is always false here, and may become true later
    isCanceled = false;

    final offlinePath = getAudioCachePath(track.id);
    final file = File(offlinePath);
    if (file.existsSync() && file.lengthSync() > 0) {
      await player.setSourceDeviceFile(offlinePath);
    } else {
      // download full audio first
      if (_preloadFuture == null) {
        preload();
      }
      try {
        await _preloadFuture;
      } catch (e) {
        // set _preloadFuture to null, allowing retry
        _preloadFuture = null;
        _downloadTask = null;

        if (e is DownloadCancelledError) {
          throw AudioCancelledError();
        } else {
          rethrow;
        }
      }
      // check whether user has changed track for playback
      if (isCanceled) {
        throw AudioCancelledError();
      }
      await player.setSourceDeviceFile(offlinePath);
    }
  }

  void preload() {
    if (_preloadFuture != null) {
      return;
    }

    _preloadFuture = _preload();
    // preload cover without await
    _preloadCover();
  }

  bool preloaded = false;

  static Future<DownloadTask?> spawnDownloadTask({
    required TrackInfoWithAlbum track,
    PreferQuality? quality,
    String? savePath,
  }) async {
    final downloadQuality =
        quality ?? Global.settings.defaultAudioQuality.value;
    final annil = Global.context.read<AnnilService>();
    final url =
        await annil.getAudioUrl(track: track.id, quality: downloadQuality);
    if (url == null) {
      return null;
    }

    savePath ??= getAudioCachePath(track.id);
    return DownloadTask(
      category: DownloadCategory.audio,
      url: url,
      savePath: savePath,
      data: TrackDownloadTaskData(info: track, quality: downloadQuality),
    );
  }

  Future<void> _preload() async {
    final savePath = getAudioCachePath(track.id);
    final file = File(savePath);
    if (!file.existsSync() || file.lengthSync() == 0) {
      final task = await spawnDownloadTask(
        track: track,
        savePath: savePath,
      );
      if (task != null) {
        await file.parent.create(recursive: true);
        Global.downloadManager.add(task);
        _downloadTask = task;
        final response = await task.start();

        final duration = int.parse(response.headers['x-duration-seconds']![0]);
        // +1 to avoid duration exceeding
        PlaybackService.durationMap.update((map) {
          map[id] = Duration(seconds: duration + 1);
        });
      } else {
        throw UnsupportedError('No available annil server found');
      }
    }
    preloaded = true;
  }

  Future<void> _preloadCover() async {
    final image = Global.proxy.coverUrl(track.id.albumId, track.id.discId);
    coverProvider = ExtendedNetworkImageProvider(image.toString());
    // ignore: use_build_context_synchronously

    if (Global.navigatorKey.currentContext != null) {
      precacheImage(coverProvider!, Global.context);
    }
  }

  void cancel() {
    _downloadTask?.cancel();
    isCanceled = true;
  }

  /////// Serialization ///////
  static AnnilAudioSource fromJson(Map<String, dynamic> json) {
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
}
