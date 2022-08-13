import 'dart:io';

import 'package:annix/services/annil/annil_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AnnilAudioSource extends Source {
  static final Dio _client = Dio();

  final AnnilController annil = Get.find();

  AnnilAudioSource({
    required this.albumId,
    required this.discId,
    required this.trackId,
    required this.quality,
    required this.track,
  });

  static Future<AnnilAudioSource> from({
    required String albumId,
    required int discId,
    required int trackId,
    PreferQuality quality = PreferQuality.Medium,
  }) async {
    final track = await (await Global.metadataSource.future)
        .getTrack(albumId: albumId, discId: discId, trackId: trackId);
    return AnnilAudioSource(
      albumId: albumId,
      discId: discId,
      trackId: trackId,
      quality: quality,
      track: track!,
    );
  }

  final String albumId;
  final int discId;
  final int trackId;
  final PreferQuality quality;
  final Track track;

  Future<void>? _preloadFuture;

  String get id {
    return "$albumId/$discId/$trackId";
  }

  @override
  Future<void> setOnPlayer(AudioPlayer player) async {
    final offlinePath = getAudioCachePath(albumId, discId, trackId);
    if (await File(offlinePath).exists()) {
      await player.setSourceDeviceFile(offlinePath);
    } else {
      // download full audio first
      if (_preloadFuture == null) {
        preload();
      }
      await _preloadFuture;
      // double check whether current song is still this track
      if (Provider.of<PlayerService>(Global.context, listen: false).playing ==
          this) {
        await player.setSourceDeviceFile(offlinePath);
      }
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
    final offlinePath = getAudioCachePath(albumId, discId, trackId);
    final file = File(offlinePath);
    if (!await file.exists()) {
      final url = annil.clients.value.getAudioUrl(
          albumId: albumId, discId: discId, trackId: trackId, quality: quality);
      if (url != null) {
        await file.parent.create(recursive: true);
        final tmpPath = "$offlinePath.tmp";
        /*final response = */ await _client.download(url, tmpPath);
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

  TrackIdentifier get identifier =>
      TrackIdentifier(albumId: albumId, discId: discId, trackId: trackId);
}
