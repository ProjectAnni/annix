import 'dart:typed_data';

import 'package:annix/services/audio_source.dart';
import 'package:annix/services/global.dart';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AnnilClient {
  final Dio client = Dio();
  final String baseUrl;
  final String authorization;

  AnnilClient({
    required this.baseUrl,
    required this.authorization,
  });

  Future<dynamic> _request({
    required String path,
    ResponseType responseType = ResponseType.bytes,
  }) async {
    var resp = await client.get(
      '$baseUrl/$path',
      options: Options(
        responseType: responseType,
        headers: {
          'Authorization': this.authorization,
        },
      ),
    );
    return resp.data;
  }

  Future<Map<String, List<String>>> getAlbums() async {
    Map<String, dynamic> result = await _request(
      path: 'albums',
      responseType: ResponseType.json,
    );
    return result.map(
      (k, v) =>
          MapEntry(k, (v as List<dynamic>).map((e) => e.toString()).toList()),
    );
  }

  Future<AudioSource> getAudio({
    required String catalog,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
  }) {
    return AnnilAudioSource.create(
      annil: this,
      catalog: catalog,
      trackId: trackId,
      preferBitrate: preferBitrate,
    );
  }

  Future<Uint8List> getCover({required String catalog}) async {
    return await _request(
      path: '$catalog/cover',
      responseType: ResponseType.bytes,
    );
  }

  String getCoverUrl({required String catalog}) {
    return '$baseUrl/$catalog/cover?auth=$authorization';
  }
}

class AnnilAudioSource extends ModifiedLockCachingAudioSource {
  final String catalog;
  final int trackId;

  AnnilAudioSource._({
    required String baseUri,
    required String authorization,
    required this.catalog,
    required this.trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
    required MediaItem tag,
  }) : super(
          Uri.parse(
            '$baseUri/$catalog/$trackId?auth=$authorization&prefer_bitrate=${preferBitrate.toBitrateString()}',
          ),
          tag: tag,
        );

  static Future<AnnilAudioSource> create({
    required AnnilClient annil,
    required String catalog,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
  }) async {
    var track = await Global.metadataSource
        .getTrack(catalog: catalog, trackIndex: trackId - 1);
    return AnnilAudioSource._(
      baseUri: annil.baseUrl,
      authorization: annil.authorization,
      catalog: catalog,
      trackId: trackId,
      preferBitrate: preferBitrate,
      tag: MediaItem(
        id: '$catalog/$trackId',
        title: track?.title ?? "Unknown Title",
        album: track?.disc.album.title ?? "Unknown Album",
        artist: track?.artist,
        artUri: Uri.parse(annil.getCoverUrl(catalog: catalog)),
      ),
    );
  }
}

enum PreferBitrate {
  Low,
  Medium,
  High,
  Lossless,
}

extension PreferBitrateToString on PreferBitrate {
  String toBitrateString() {
    switch (this) {
      case PreferBitrate.Low:
        return "low";
      case PreferBitrate.Medium:
        return "medium";
      case PreferBitrate.High:
        return "high";
      case PreferBitrate.Lossless:
        return "lossless";
    }
  }
}
