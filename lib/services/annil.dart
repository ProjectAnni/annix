import 'package:annix/services/audio_source.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/platform_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
    show PlatformCircularProgressIndicator;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AnnilClient {
  final Dio client;
  final String baseUrl;
  final String authorization;

  AnnilClient({
    required this.baseUrl,
    required this.authorization,
  }) : client = Dio(BaseOptions(baseUrl: baseUrl));

  Future<dynamic> _request({
    required String path,
    ResponseType responseType = ResponseType.bytes,
  }) async {
    var resp = await client.get(
      '$path',
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
    List<dynamic> result =
        await _request(path: '/albums', responseType: ResponseType.json);
    return result.map((e) => e.toString()).toList();
  }

  Future<AudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
  }) {
    return AnnilAudioSource.create(
      annil: this,
      albumId: albumId,
      discId: discId,
      trackId: trackId,
      preferBitrate: preferBitrate,
    );
  }

  Widget cover({required String albumId, int? discId}) {
    return Builder(
      builder: (context) {
        return CachedNetworkImage(
          imageUrl: _getCoverUrl(albumId: albumId, discId: discId),
          placeholder: (context, url) => SizedBox.square(
            dimension: 64,
            child: Center(
              child: PlatformCircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Icon(context.icons.error),
          fit: BoxFit.scaleDown,
          filterQuality: FilterQuality.medium,
        );
      },
    );
  }

  String _getCoverUrl({required String albumId, int? discId}) {
    if (discId == null) {
      return '$baseUrl/$albumId/cover?auth=$authorization';
    } else {
      return '$baseUrl/$albumId/$discId/cover?auth=$authorization';
    }
  }
}

class AnnilAudioSource extends ModifiedLockCachingAudioSource {
  final String albumId;
  final int discId;
  final int trackId;

  AnnilAudioSource._({
    required String baseUri,
    required String authorization,
    required this.albumId,
    required this.discId,
    required this.trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
    required MediaItem tag,
  }) : super(
          Uri.parse(
            '$baseUri/$albumId/$discId/$trackId?auth=$authorization&prefer_bitrate=${preferBitrate.toBitrateString()}',
          ),
          tag: tag,
        );

  static Future<AnnilAudioSource> create({
    required AnnilClient annil,
    required String albumId,
    required int discId,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
  }) async {
    var track = await Global.metadataSource!
        .getTrack(albumId: albumId, discId: discId, trackId: trackId);
    return AnnilAudioSource._(
      baseUri: annil.baseUrl,
      authorization: annil.authorization,
      albumId: albumId,
      discId: discId,
      trackId: trackId,
      preferBitrate: preferBitrate,
      tag: MediaItem(
        id: '$albumId/$discId/$trackId',
        title: track?.title ?? "Unknown Title",
        album: track?.disc.album.title ?? "Unknown Album",
        artist: track?.artist,
        artUri: Uri.parse(annil._getCoverUrl(albumId: albumId)),
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
