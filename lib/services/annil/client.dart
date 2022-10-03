import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/global.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/network/http_plus_adapter.dart';
import 'package:annix/services/network/network.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class AnnilService extends ChangeNotifier {
  final BuildContext context;
  final Dio _client = Dio()
    ..httpClientAdapter =
        createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value);

  List<String> albums = [];

  AnnilService(this.context) {
    final network = context.read<NetworkService>();
    network.addListener(() => reloadClients());

    Global.settings.enableHttp2ForAnnil.addListener(() {
      _client.httpClientAdapter =
          createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value);
    });
  }

  Future<void> createRemoteClient({
    required String name,
    required String url,
    required String token,
    required int priority,
    required String remoteId,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = Global.context.read<LocalDatabase>();
    await db.localAnnilServers.insertOne(
      LocalAnnilServersCompanion.insert(
        name: name,
        url: url,
        token: token,
        priority: priority,
        remoteId: Value(remoteId),
      ),
    );
  }

  Future<void> createLocalClient({
    required String name,
    required String url,
    required String token,
    required int priority,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = Global.context.read<LocalDatabase>();
    await db.localAnnilServers.insertOne(
      LocalAnnilServersCompanion.insert(
        name: name,
        url: url,
        token: token,
        priority: priority,
      ),
    );
  }

  /// Keep sync with new credential list
  Future<void> sync(List<AnnilToken> remoteList) async {
    final db = Global.context.read<LocalDatabase>();
    final clients = Global.context.read<List<LocalAnnilServer>>();

    final toUpdate = clients
        .map((client) {
          // local annil
          if (client.remoteId == null) {
            return null;
          }

          return remoteList
              .firstWhere((remote) => remote.id == client.remoteId);
        })
        .whereType<LocalAnnilServer>()
        .toList();
    final toUpdateIds = toUpdate.map((e) => e.remoteId).toList();
    final toRemove = clients
        .map((client) {
          if (client.remoteId == null) {
            return null;
          }

          return toUpdate.contains(client) ? null : client.id;
        })
        .whereType<int>()
        .toList();
    final toAdd =
        remoteList.where((remote) => !toUpdateIds.contains(remote.id));
    await db.transaction(() async {
      // exist both in local and remote, update client info
      for (final client in toUpdate) {
        await (db.localAnnilServers.update()
              ..where((tbl) => tbl.id.equals(client.id)))
            .write(
          LocalAnnilServersCompanion(
            name: Value(client.name),
            url: Value(client.url),
            token: Value(client.token),
            priority: Value(client.priority),
          ),
        );
      }
      // remove deleted servers
      await db.localAnnilServers.deleteWhere((tbl) => tbl.id.isIn(toRemove));
      // add new servers
      await db.batch(
        (batch) => batch.insertAll(
          db.localAnnilServers,
          toAdd.map(
            (e) => LocalAnnilServersCompanion.insert(
              name: e.name,
              url: e.url,
              token: e.token,
              priority: e.priority,
              remoteId: Value(e.id),
              // TODO: controlled property
              // controlled: e.controlled,
            ),
          ),
        ),
      );
    });
  }

  static Future<List<LocalAnnilServer>> _getActiveServerByAlbumId(
      String albumId) async {
    final db = Global.context.read<LocalDatabase>();
    return await db.annilToUse(albumId).get();
  }

  Future<String?> getAudioUrl({
    required TrackIdentifier track,
    required PreferQuality quality,
  }) async {
    final servers = await _getActiveServerByAlbumId(track.albumId);
    if (servers.isEmpty) {
      return null;
    } else {
      final server = servers.first;
      return '${server.url}/${track.albumId}/${track.discId}/${track.trackId}?auth=${server.token}&quality=$quality';
    }
  }

  Future<Uri?> getCoverUrl({required String albumId, int? discId}) async {
    if (NetworkService.isOnline) {
      final servers = await _getActiveServerByAlbumId(albumId);
      if (servers.isEmpty) {
        return null;
      } else {
        final server = servers.first;

        if (discId == null) {
          return Uri.parse('${server.url}/$albumId/cover');
        } else {
          return Uri.parse('${server.url}/$albumId/$discId/cover');
        }
      }
    }
    return null;
  }

  /// Refresh all annil servers
  Future<void> reloadClients() async {
    if (NetworkService.isOnline) {
      final servers = context.watch<List<LocalAnnilServer>>();
      await Future.wait(servers.map((server) async {
        try {
          await updateAlbums(server);
        } catch (e) {
          FLog.warning(
            text: 'Failed to refresh annil client ${server.name}',
            exception: e,
          );
        }
        return;
      }));
    } else {
      final localAlbums = await getCachedAlbums();
      albums.replaceRange(0, albums.length, localAlbums);
    }
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

  /// Get the available album list of an Annil server.
  Future<void> updateAlbums(LocalAnnilServer server) async {
    try {
      final response = await _client.getUri(
        Uri.parse('${server.url}/albums'),
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Authorization': server.token,
            'If-None-Match': server.etag,
          },
        ),
      );
      final newETag = response.headers['etag']![0];
      FLog.debug(
        text:
            'Annil cache MISSED, old etag: ${server.etag}, new etag: $newETag',
      );
      // TODO: update etag
      // eTag = newETag;

      albums = (response.data as List<dynamic>)
          .map((album) => album.toString())
          .toList();
    } on DioError catch (e) {
      if (e.response?.statusCode == 304) {
        FLog.trace(text: 'Annil cache HIT, etag: ${server.etag}');
      } else {
        // TODO: update etag
        // eTag = '';
        rethrow;
      }
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
