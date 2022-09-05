import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AudioCancelledError extends Error {}

class AnnilAudioSource extends Source {
  static final Dio _client = Dio();

  AnnilAudioSource({
    required this.track,
    this.quality = PreferQuality.Medium,
  });

  static Future<AnnilAudioSource?> from(
    BuildContext context, {
    required TrackIdentifier id,
    PreferQuality quality = PreferQuality.Medium,
  }) async {
    final MetadataService metadata = context.read();
    final track = await metadata.getTrack(id);
    if (track != null) {
      return AnnilAudioSource(
        quality: quality,
        track: TrackInfoWithAlbum.fromTrack(track),
      );
    }

    return null;
  }

  final PreferQuality quality;
  final TrackInfoWithAlbum track;

  Future<void>? _preloadFuture;

  TrackIdentifier get identifier => track.id;

  String get id => track.id.toString();

  @override
  Future<void> setOnPlayer(AudioPlayer player) async {
    // when setOnPlayer was called, player expects to play current track
    // but use may change track before player is ready
    // so isCanceled is always false here, and may become true later
    isCanceled = false;

    final offlinePath = getAudioCachePath(track.id);
    if (await File(offlinePath).exists()) {
      await player.setSourceDeviceFile(offlinePath);
    } else {
      // download full audio first
      if (_preloadFuture == null) {
        preload();
      }
      await _preloadFuture;
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
  }

  bool preloaded = false;

  Future<void> _preload() async {
    final annil = Global.context.read<CombinedOnlineAnnilClient>();
    final offlinePath = getAudioCachePath(track.id);
    final file = File(offlinePath);
    if (!await file.exists()) {
      final url = annil.getAudioUrl(id: track.id, quality: quality);
      if (url != null) {
        await file.parent.create(recursive: true);
        final tmpPath = "$offlinePath.tmp";
        /*final response = */
        await _client.download(url, tmpPath);
        // final duration = int.parse(response.headers['x-duration-seconds']![0]);
        // PlayerController player = Provider.of(Global.context, listen: false);
        // player.durationMap[id] =
        //     Duration(seconds: duration + 1); // +1 to avoid duration exceeding
        File(tmpPath).rename(offlinePath);
      } else {
        throw UnsupportedError("No available annil server found");
      }
    }
    preloaded = true;
  }

  bool isCanceled = false;

  void cancel() {
    // TODO: cancel download if necessary
    isCanceled = true;
  }
}
