import 'dart:io';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

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

  Future<void>? preloadFuture;

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
      if (this.preloadFuture == null) {
        this.preload();
      }
      await this.preloadFuture;
      await player.setSourceDeviceFile(offlinePath);
    }
  }

  void preload() {
    this.preloadFuture = _preload();
  }

  Future<void> _preload() async {
    final offlinePath = getAudioCachePath(albumId, discId, trackId);
    if (!await File(offlinePath).exists()) {
      final url = annil.clients.value.getAudioUrl(
          albumId: albumId, discId: discId, trackId: trackId, quality: quality);
      if (url != null) {
        final tmpPath = offlinePath + ".tmp";
        await _client.download(url, tmpPath);
        File(tmpPath).rename(offlinePath);
      } else {
        throw UnsupportedError("No available annil server found");
      }
    }
  }
}

abstract class BaseAnnilClient {
  Future<List<String>> getAlbums();

  Uri getCoverUrl({required String albumId, int? discId});
}

class OnlineAnnilClient implements BaseAnnilClient {
  final Dio client;
  final String id;
  String name;
  String url;
  String token;
  int priority;
  final bool local;

  // cached album list in client
  String eTag = "";
  List<String> albums = [];

  OnlineAnnilClient._({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.priority,
    this.local = false,
  }) : client = Dio(BaseOptions(baseUrl: url));

  factory OnlineAnnilClient.remote({
    required String id,
    required String name,
    required String url,
    required String token,
    required int priority,
  }) {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return OnlineAnnilClient._(
      id: id,
      name: name,
      url: url,
      token: token,
      priority: priority,
      local: false,
    );
  }

  factory OnlineAnnilClient.local({
    required String name,
    required String url,
    required String token,
    required int priority,
  }) =>
      OnlineAnnilClient._(
        id: Uuid().v4(),
        name: name,
        url: url,
        token: token,
        priority: priority,
        local: true,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'token': token,
      'priority': priority,
      'local': local,
      'albums': albums,
      'etag': eTag,
    };
  }

  factory OnlineAnnilClient.fromJson(Map<String, dynamic> json) {
    final client = OnlineAnnilClient._(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      token: json['token'] as String,
      priority: json['priority'] as int,
      local: json['local'] as bool,
    );
    client.albums = (json['albums'] as List<dynamic>)
        .map((album) => album as String)
        .toList();
    client.eTag = json['etag'] as String;
    return client;
  }

  /// Get the available album list of an Annil server.
  Future<List<String>> getAlbums() async {
    try {
      final response = await client.get(
        '/albums',
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Authorization': token,
            'If-None-Match': eTag,
          },
        ),
      );
      final newETag = response.headers['etag']![0];
      FLog.debug(
        text: "Annil cache MISSED, old etag: $eTag, new etag: $newETag",
      );
      eTag = newETag;

      albums = (response.data as List<dynamic>)
          .map((album) => album.toString())
          .toList();
    } on DioError catch (e) {
      if (e.response?.statusCode == 304) {
        FLog.trace(text: "Annil cache HIT, etag: $eTag");
      } else {
        rethrow;
      }
    }
    return List.unmodifiable(albums);
  }

  Uri getCoverUrl({required String albumId, int? discId}) {
    if (discId == null) {
      return Uri.parse('$url/$albumId/cover');
    } else {
      return Uri.parse('$url/$albumId/$discId/cover');
    }
  }
}

String getAudioCachePath(String albumId, int discId, int trackId) {
  return p.join(Global.storageRoot, 'audio', albumId, "${discId}_$trackId");
}

enum PreferQuality {
  Low,
  Medium,
  High,
  Lossless,
}

extension PreferQualityToString on PreferQuality {
  String toQualityString() {
    switch (this) {
      case PreferQuality.Low:
        return "low";
      case PreferQuality.Medium:
        return "medium";
      case PreferQuality.High:
        return "high";
      case PreferQuality.Lossless:
        return "lossless";
    }
  }
}

class OfflineAnnilClient implements BaseAnnilClient {
  static OfflineAnnilClient _instance = OfflineAnnilClient._();
  static OfflineAnnilClient get instance => OfflineAnnilClient._instance;

  OfflineAnnilClient._();

  @override
  Future<List<String>> getAlbums() async {
    final root = p.join(Global.storageRoot, 'audio');
    return Directory(root)
        .list()
        .where((entry) {
          if (entry is! Directory) {
            return false;
          }
          // return true if music file exists (any file with no extension)
          return entry
              .listSync()
              .any((e) => e is File && !p.basename(e.path).contains('.'));
        })
        .map((entry) => p.basename(entry.path))
        .toList();
  }

  @override
  Uri getCoverUrl({required String albumId, int? discId}) {
    // placeholder, would never be called
    throw UnimplementedError();
  }

  static String cacheKey(String albumId, {int? discId}) {
    return discId == null ? "$albumId" : "$albumId/$discId";
  }

  bool isAvailable({
    required String albumId,
    required int discId,
    required int trackId,
  }) {
    final path = getAudioCachePath(albumId, discId, trackId);
    return File(path).existsSync();
  }
}
