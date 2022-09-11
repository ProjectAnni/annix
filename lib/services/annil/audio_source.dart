import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/network/http_plus_adapter.dart';
import 'package:annix/services/player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AudioCancelledError extends Error {}

class AnnilAudioSource extends Source {
  static final Dio _client = Dio()
    ..httpClientAdapter = createHttpPlusAdapter(false);

  final PreferQuality quality;
  final TrackInfoWithAlbum track;
  ExtendedNetworkImageProvider? coverProvider;

  bool isCanceled = false;
  Future<void>? _preloadFuture;

  TrackIdentifier get identifier => track.id;

  AnnilAudioSource({
    required this.track,
    this.quality = PreferQuality.Medium,
  });

  static Future<AnnilAudioSource?> from({
    required MetadataService metadata,
    required TrackIdentifier id,
    PreferQuality quality = PreferQuality.Medium,
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
      try {
        await _preloadFuture;
      } catch (e) {
        // set _preloadFuture to null, allowing retry
        _preloadFuture = null;
        rethrow;
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

  Future<void> _preload() async {
    final offlinePath = getAudioCachePath(track.id);
    final file = File(offlinePath);
    if (!file.existsSync()) {
      final CombinedOnlineAnnilClient annil = Global.context.read();
      final url = annil.getAudioUrl(id: track.id, quality: quality);
      if (url != null) {
        await file.parent.create(recursive: true);
        final tmpPath = "$offlinePath.tmp";
        final response = await _client.download(url, tmpPath);
        final duration = int.parse(response.headers['x-duration-seconds']![0]);
        // +1 to avoid duration exceeding
        PlayerService.durationMap.update((map) {
          map[id] = Duration(seconds: duration + 1);
        });
        File(tmpPath).rename(offlinePath);
      } else {
        throw UnsupportedError("No available annil server found");
      }
    }
    preloaded = true;
  }

  Future<void> _preloadCover() async {
    final image = Global.proxy.coverUrl(track.id.albumId, track.id.discId);
    coverProvider = ExtendedNetworkImageProvider(image.toString());
    // ignore: use_build_context_synchronously
    precacheImage(coverProvider!, Global.context);
  }

  void cancel() {
    // TODO: cancel download if necessary
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
