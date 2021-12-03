import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';

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

  Future<List<String>> getAlbums() async {
    return await _request(
      path: 'albums',
      responseType: ResponseType.json,
    );
  }

  AnnilAudioSource getAudio({
    required String catalog,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Loseless,
  }) {
    return AnnilAudioSource(
      baseUri: baseUrl,
      authorization: authorization,
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
}

class AnnilAudioSource extends LockCachingAudioSource {
  final String catalog;
  final int trackId;

  AnnilAudioSource({
    required String baseUri,
    required String authorization,
    required this.catalog,
    required this.trackId,
    PreferBitrate preferBitrate = PreferBitrate.Loseless,
  }) : super(
          Uri.parse(
            '$baseUri/$catalog/$trackId?prefer_bitrate=${preferBitrate.toBitrateString()}',
          ),
          headers: {
            'Authorization': authorization,
          },
        );
}

enum PreferBitrate {
  Low,
  Medium,
  High,
  Loseless,
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
      case PreferBitrate.Loseless:
        return "loseless";
    }
  }
}
