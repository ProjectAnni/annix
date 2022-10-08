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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:collection/collection.dart';

class AnnilService extends ChangeNotifier {
  final BuildContext context;
  final Dio _client = Dio()
    ..httpClientAdapter =
        createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value);

  List<LocalAnnilServer> servers = [];
  Map<int, String?> etags = {};
  List<String> albums = [];

  AnnilService(this.context) {
    _client.interceptors.add(RetryInterceptor(
      dio: _client,
      logPrint: (text) => FLog.error(text: text),
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    final db = context.read<LocalDatabase>();
    db.localAnnilCaches.select().get().then((value) {
      etags.addAll(
          Map.fromEntries(value.map((e) => MapEntry(e.annilId, e.etag))));
    });
    final annilServersStream = db.sortedAnnilServers().watch();
    annilServersStream.listen((event) {
      if (!listEquals(event, servers)) {
        servers = event;
        reload();
      }
    });

    final network = context.read<NetworkService>();
    network.addListener(() => reload());

    Global.settings.enableHttp2ForAnnil.addListener(() {
      _client.httpClientAdapter =
          createHttpPlusAdapter(Global.settings.enableHttp2ForAnnil.value);
    });
  }

  Future<void> addRemoteServer({
    required String name,
    required String url,
    required String token,
    required int priority,
    required String remoteId,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = context.read<LocalDatabase>();
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

  Future<void> addLocalServer({
    required String name,
    required String url,
    required String token,
    required int priority,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = context.read<LocalDatabase>();
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
    final db = context.read<LocalDatabase>();
    final toUpdate = servers
        .map((server) {
          // local annil
          if (server.remoteId == null) {
            return null;
          }

          return remoteList
              .firstWhereOrNull((remote) => remote.id == server.remoteId);
        })
        .whereType<AnnilToken>()
        .toList();
    final toUpdateIds = toUpdate.map((e) => e.id).toList();
    final toRemove = servers
        .map((server) {
          if (server.remoteId == null) {
            return null;
          }

          return toUpdate.where((e) => server.remoteId == e.id).isNotEmpty
              ? null
              : server.id;
        })
        .whereType<int>()
        .toList();
    final toAdd =
        remoteList.where((remote) => !toUpdateIds.contains(remote.id));
    await db.transaction(() async {
      // exist both in local and remote, update server info
      for (final e in toUpdate) {
        await (db.localAnnilServers.update()
              ..where((tbl) => tbl.remoteId.equals(e.id)))
            .write(
          LocalAnnilServersCompanion(
            name: Value(e.name),
            url: Value(e.url),
            token: Value(e.token),
            priority: Value(e.priority),
          ),
        );
      }
      // remove deleted servers
      await db.localAnnilServers.deleteWhere((tbl) => tbl.id.isIn(toRemove));
      await db.localAnnilAlbums
          .deleteWhere((tbl) => tbl.annilId.isIn(toRemove));
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

  Future<List<LocalAnnilServer>> _getActiveServerByAlbumId(
      String albumId) async {
    final db = context.read<LocalDatabase>();
    return await db.annilToUse(albumId).get();
  }

  Future<String?> getAudioUrl({
    required TrackIdentifier track,
    required PreferQuality quality,
  }) async {
    final servers = await _getActiveServerByAlbumId(track.albumId);
    if (servers.isNotEmpty) {
      for (final server in servers) {
        if (etags[server.id] != null) {
          return '${server.url}/${track.albumId}/${track.discId}/${track.trackId}?auth=${server.token}&quality=$quality';
        }
      }
    }
    return null;
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
  Future<void> reload() async {
    final db = context.read<LocalDatabase>();
    final albumList = <String>{};
    if (NetworkService.isOnline) {
      await Future.wait(servers.map((server) async {
        try {
          await updateAlbums(server);
        } catch (e) {
          FLog.warning(
            text: 'Failed to refresh annil ${server.name}',
            exception: e,
          );
        }
        return;
      }));
      albumList.addAll(await db.availableAlbums().get());
    }
    albumList.addAll(await getCachedAlbums());
    albums = albumList.toList();
    notifyListeners();
  }

  bool isAvailable(TrackIdentifier id) {
    return isCacheAvailable(id) ||
        (NetworkService.isOnline && albums.contains(id.albumId));
  }

  static Future<Set<String>> getCachedAlbums() async {
    final root = Directory(p.join(Global.storageRoot, 'audio'));
    if (!root.existsSync()) {
      return {};
    }

    return root
        .list()
        .where((entry) {
          if (entry is! Directory) {
            return false;
          }
          // return true if music file exists (any file with no extension, or flac extension)
          return entry.listSync().any((e) =>
              e is File &&
              (p.basename(e.path).endsWith('.flac') ||
                  !p.basename(e.path).contains('.')));
        })
        .map((entry) => p.basename(entry.path))
        .toSet();
  }

  static bool isCacheAvailable(TrackIdentifier id) {
    final path = getAudioCachePath(id);
    return File(path).existsSync();
  }

  /// Get the available album list of an Annil server.
  Future<void> updateAlbums(LocalAnnilServer server) async {
    final db = context.read<LocalDatabase>();
    final etag = etags[server.id];

    try {
      final response = await _client.getUri(
        Uri.parse('${server.url}/albums'),
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Authorization': server.token,
            if (etag != null) 'If-None-Match': etag,
          },
        ),
      );
      final newETag = response.headers['etag']![0];
      FLog.debug(
        text: 'Annil cache MISSED, old etag: $etag, new etag: $newETag',
      );
      if (etag != newETag) {
        etags[server.id] = newETag;
        await db.transaction(() async {
          await db.updateAnnilETag(server.id, newETag);
          await db.localAnnilAlbums
              .deleteWhere((tbl) => tbl.annilId.equals(server.id));
          await db.batch((batch) => batch.insertAll(db.localAnnilAlbums, [
                for (final album in response.data as List<dynamic>)
                  LocalAnnilAlbumsCompanion.insert(
                    annilId: server.id,
                    albumId: album.toString(),
                  )
              ]));
        });
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == 304) {
        FLog.trace(text: 'Annil cache HIT, etag: $etag');
      } else {
        etags.remove(server.id);
        await db.transaction(() async {
          await db.updateAnnilETag(server.id, null);
          await db.localAnnilAlbums
              .deleteWhere((tbl) => tbl.annilId.equals(server.id));
        });
        rethrow;
      }
    }
  }
}

enum PreferQuality {
  low,
  medium,
  high,
  lossless;

  @override
  String toString() {
    switch (this) {
      case PreferQuality.low:
        return 'low';
      case PreferQuality.medium:
        return 'medium';
      case PreferQuality.high:
        return 'high';
      case PreferQuality.lossless:
        return 'lossless';
    }
  }

  factory PreferQuality.fromString(String str) {
    switch (str) {
      case 'low':
        return PreferQuality.low;
      case 'medium':
        return PreferQuality.medium;
      case 'high':
        return PreferQuality.high;
      case 'lossless':
        return PreferQuality.lossless;
      default:
        return PreferQuality.medium;
    }
  }
}
