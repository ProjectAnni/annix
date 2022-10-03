// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/global.dart';
import 'package:annix/services/network/http_plus_adapter.dart';
import 'package:annix/services/network/network.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

class AnnilService extends ChangeNotifier {
  final Map<String, AnnilClient> clients;
  final List<AnnilClient> _clients;

  List<AnnilClient> get sortedClients => _clients;
  List<String> albums = [];

  AnnilService._([List<AnnilClient> clients = const []])
      : _clients = clients,
        clients = Map.fromEntries(clients.map((e) => MapEntry(e.id, e))) {
    _sort();
  }

  bool get isEmpty => clients.isEmpty;

  bool get isNotEmpty => !isEmpty;

  void _sort() {
    _clients.sort((a, b) => b.priority - a.priority);
  }

  // TODO: load from / save to sqlite instead of shared preferences
  static AnnilService loadFromLocal() {
    final List<String>? tokens =
        Global.preferences.getStringList('annil_clients');
    if (tokens != null) {
      final clients = tokens
          .map((token) => AnnilClient.fromJson(jsonDecode(token)))
          .toList();
      return AnnilService._(clients);
    } else {
      return AnnilService._();
    }
  }

  Future<void> saveToLocal() async {
    // TODO: save to database instead of shared_preferences
    final tokens =
        clients.values.map((client) => jsonEncode(client.toJson())).toList();
    await Global.preferences.setStringList('annil_clients', tokens);
  }

  /// Keep sync with new credential list
  void sync(List<AnnilToken> remoteList) {
    final remoteIds = remoteList.map((e) => e.id).toList();
    // update existing client info
    clients.removeWhere((id, client) {
      final index = remoteIds.indexOf(id);
      if (index != -1) {
        // exist both in local and remote, update client info
        final newClient = remoteList[index];
        client.name = newClient.name;
        client.url = newClient.url;
        client.token = newClient.token;
        client.priority = newClient.priority;
        remoteIds.removeAt(index);
        remoteList.removeAt(index);
      } else if (!client.local) {
        // remote client which only exist in local, remove it
        return true;
      }

      // do not remove the remaining
      return false;
    });

    // add new clients
    clients.addAll(
      Map.fromEntries(
        remoteList
            .map((e) => AnnilClient.remote(
                  id: e.id,
                  name: e.name,
                  url: e.url,
                  token: e.token,
                  priority: e.priority,
                ))
            .map((c) => MapEntry(c.id, c)),
      ),
    );

    // sort with priority
    _clients.clear();
    _clients.addAll(clients.values);
    _sort();
    notifyListeners();
  }

  String? getAudioUrl({
    required TrackIdentifier id,
    required PreferQuality quality,
  }) {
    for (final client in _clients) {
      if (client.albums.contains(id.albumId)) {
        return '${client.url}/${id.albumId}/${id.discId}/${id.trackId}?auth=${client.token}&quality=$quality';
      }
    }

    return null;
  }

  Uri? getCoverUrl({required String albumId, int? discId}) {
    if (NetworkService.isOnline) {
      for (final client in _clients) {
        if (client.albums.contains(albumId)) {
          return client.getCoverUrl(albumId: albumId, discId: discId);
        }
      }
    }
    return null;
  }

  /// Refresh all annil servers
  Future<void> reloadClients() async {
    if (NetworkService.isOnline) {
      final newAlbums = (await Future.wait(clients.values.map((client) async {
        try {
          return await client.getAlbums();
        } catch (e) {
          FLog.warning(
            text: 'Failed to refresh annil client ${client.name}',
            exception: e,
          );
          // TODO: use local copy
          return <String>[];
        }
      })))
          .expand((e) => e)
          .toSet()
          .toList();
      albums.replaceRange(0, albums.length, newAlbums);
      await saveToLocal();
    } else {
      final localAlbums = await getCachedAlbums();
      albums.replaceRange(0, albums.length, localAlbums);
    }
    notifyListeners();
  }

  bool isAvailable(TrackIdentifier id) {
    return isCacheAvailable(id) ||
        (NetworkService.isOnline && albums.contains(id.albumId));
  }

  static Future<List<String>> getCachedAlbums() async {
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

  static bool isCacheAvailable(TrackIdentifier id) {
    final path = getAudioCachePath(id);
    return File(path).existsSync();
  }
}

class AnnilClient {
  final Dio client;
  final String id;
  String name;
  String url;
  String token;
  int priority;
  final bool local;

  // cached album list in client
  String eTag = '';
  List<String> albums = [];

  AnnilClient._({
    required this.id,
    required this.name,
    required this.url,
    required this.token,
    required this.priority,
    this.local = false,
  }) : client = Dio(BaseOptions(baseUrl: url))
          ..httpClientAdapter =
              createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value) {
    Global.settings.enableHttp2ForAnnil.addListener(() {
      client.httpClientAdapter =
          createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value);
    });
  }

  factory AnnilClient.remote({
    required String id,
    required String name,
    required String url,
    required String token,
    required int priority,
  }) {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return AnnilClient._(
      id: id,
      name: name,
      url: url,
      token: token,
      priority: priority,
      local: false,
    );
  }

  factory AnnilClient.local({
    required String name,
    required String url,
    required String token,
    required int priority,
  }) =>
      AnnilClient._(
        id: const Uuid().v4(),
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
        text: 'Annil cache MISSED, old etag: $eTag, new etag: $newETag',
      );
      eTag = newETag;

      albums = (response.data as List<dynamic>)
          .map((album) => album.toString())
          .toList();
    } on DioError catch (e) {
      if (e.response?.statusCode == 304) {
        FLog.trace(text: 'Annil cache HIT, etag: $eTag');
      } else {
        eTag = '';
        albums = [];
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

enum PreferQuality {
  Low,
  Medium,
  High,
  Lossless;

  @override
  String toString() {
    switch (this) {
      case PreferQuality.Low:
        return 'low';
      case PreferQuality.Medium:
        return 'medium';
      case PreferQuality.High:
        return 'high';
      case PreferQuality.Lossless:
        return 'lossless';
    }
  }

  factory PreferQuality.fromString(String str) {
    switch (str) {
      case 'low':
        return PreferQuality.Low;
      case 'medium':
        return PreferQuality.Medium;
      case 'high':
        return PreferQuality.High;
      case 'lossless':
        return PreferQuality.Lossless;
      default:
        return PreferQuality.Medium;
    }
  }
}
