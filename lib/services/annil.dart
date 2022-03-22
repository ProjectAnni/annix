import 'dart:convert';

import 'package:annix/services/audio_source.dart';
import 'package:annix/services/global.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:uuid/uuid.dart';

class CombinedAnnilClient extends ChangeNotifier {
  final Map<String, AnnilClient> _clients = Map();
  bool get hasClient => _clients.isNotEmpty;

  /// Load state from shared preferences
  static Future<CombinedAnnilClient> load() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    final combined = CombinedAnnilClient();
    if (tokens != null) {
      for (String token in tokens) {
        final client = AnnilClient.fromJson(jsonDecode(token));
        combined._clients[client.id] = client;
      }
    }
    return combined;
  }

  /// Save the current state of the combined client to shared preferences
  Future<void> save() async {
    final tokens =
        _clients.values.map((client) => jsonEncode(client.toJson())).toList();
    Global.preferences.setStringList("annil_clients", tokens);
  }

  /// Add a list of clients to the combined client
  Future<void> addAll(List<AnnilClient> clients) async {
    _clients.addAll(Map.fromEntries(clients.map((c) => MapEntry(c.id, c))));
    await save();
  }

  /// Remove all remote annil sources
  Future<void> removeRemote() async {
    _clients.removeWhere((_, client) => !client.local);
  }

  Future<void> refresh() async {
    await Future.wait(_clients.values.map((client) => client.getAlbums()));
    notifyListeners();
  }

  // TODO: cache this list
  List<String> get albums {
    List<String> _albums = [];
    _clients.values.forEach((client) {
      _albums.addAll(client.albums);
    });
    return _albums.toSet().toList();
  }

  Future<AnnilAudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
    PreferBitrate preferBitrate = PreferBitrate.Lossless,
  }) {
    // FIXME: choose the correct annil server
    return AnnilAudioSource.create(
      annil: _clients.entries.first.value,
      albumId: albumId,
      discId: discId,
      trackId: trackId,
      preferBitrate: preferBitrate,
    );
  }

  Widget cover({required String albumId, int? discId}) {
    for (final client in _clients.values) {
      if (client.albums.contains(albumId)) {
        return ExtendedImage.network(
          client.getCoverUrl(albumId: albumId, discId: discId),
          cache: true,
          fit: BoxFit.scaleDown,
          filterQuality: FilterQuality.medium,
        );
      }
    }
    return Text("No cover");
  }
}

class AnnilClient {
  final Dio client;
  final String id;
  final String name;
  final String url;
  final String token;
  final int priority;
  final bool local;

  // cached album list in client
  List<String> albums = [];

  AnnilClient._({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.priority,
    this.local = false,
  }) : client = Dio(BaseOptions(baseUrl: url));

  factory AnnilClient.remote({
    required String id,
    required String name,
    required String url,
    required String token,
    required int priority,
  }) =>
      AnnilClient._(
        id: id,
        name: name,
        url: url,
        token: token,
        priority: priority,
        local: false,
      );

  factory AnnilClient.local({
    required String name,
    required String url,
    required String token,
    required int priority,
  }) =>
      AnnilClient._(
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
    };
  }

  factory AnnilClient.fromJson(Map<String, dynamic> json) {
    final client = AnnilClient._(
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
    return client;
  }

  Future<dynamic> _request({
    required String path,
    ResponseType responseType = ResponseType.bytes,
  }) async {
    var resp = await client.get(
      '$path',
      options: Options(
        responseType: responseType,
        headers: {
          'Authorization': this.token,
        },
      ),
    );
    return resp.data;
  }

  Future<List<String>> getAlbums() async {
    List<dynamic> result =
        await _request(path: '/albums', responseType: ResponseType.json);
    albums = result.map((e) => e.toString()).toList();
    return List.unmodifiable(albums);
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

  String getCoverUrl({required String albumId, int? discId}) {
    if (discId == null) {
      return '$url/$albumId/cover';
    } else {
      return '$url/$albumId/$discId/cover';
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
    PreferBitrate preferBitrate = PreferBitrate.Medium,
  }) async {
    var track = await Global.metadataSource!
        .getTrack(albumId: albumId, discId: discId, trackId: trackId);
    return AnnilAudioSource._(
      baseUri: annil.url,
      authorization: annil.token,
      albumId: albumId,
      discId: discId,
      trackId: trackId,
      preferBitrate: preferBitrate,
      tag: MediaItem(
        id: '$albumId/$discId/$trackId',
        title: track?.title ?? "Unknown Title",
        album: track?.disc.album.title ?? "Unknown Album",
        artist: track?.artist,
        artUri: Uri.parse(annil.getCoverUrl(albumId: albumId)),
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
