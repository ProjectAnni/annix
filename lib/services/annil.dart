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

  LockCachingAudioSource getAudio(
      {required String catalog, required int trackId}) {
    var url = Uri.parse('$baseUrl/$catalog/$trackId?prefer_bitrate=loseless');
    print(url);
    return LockCachingAudioSource(
      url,
      headers: {
        'Authorization': this.authorization,
      },
    );
  }

  // TODO: fix type here
  Future<dynamic> getCover({required String catalog}) async {
    return await _request(
      path: '$catalog/cover',
      responseType: ResponseType.bytes,
    );
  }
}
