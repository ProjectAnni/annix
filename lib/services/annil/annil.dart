import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/global.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/network/network.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:collection/collection.dart';

class AnnilService extends ChangeNotifier {
  final Ref<Object?> ref;
  final Dio _client = Dio();

  List<LocalAnnilServer> servers = [];
  Map<int, String?> etags = {};
  List<String> albums = [];

  AnnilService(this.ref) {
    _client.interceptors.add(RetryInterceptor(
      dio: _client,
      logPrint: (final text) => FLog.error(text: text),
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    final db = ref.read(localDatabaseProvider);
    db.localAnnilCaches.select().get().then((final value) {
      etags.addAll(
          Map.fromEntries(value.map((final e) => MapEntry(e.annilId, e.etag))));
    });
    final annilServersStream = db.sortedAnnilServers().watch();
    annilServersStream.listen((final event) {
      if (!listEquals(event, servers)) {
        servers = event;
        reload();
      }
    });

    final network = ref.read(networkProvider);
    network.addListener(() => reload());
  }

  Future<void> addRemoteServer({
    required final String name,
    required String url,
    required final String token,
    required final int priority,
    required final String remoteId,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = ref.read(localDatabaseProvider);
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
    required final String name,
    required String url,
    required final String token,
    required final int priority,
  }) async {
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    final db = ref.read(localDatabaseProvider);
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
  Future<void> sync(final List<AnnilToken> remoteList) async {
    final db = ref.read(localDatabaseProvider);
    final toUpdate = servers
        .map((final server) {
          // local annil
          if (server.remoteId == null) {
            return null;
          }

          return remoteList
              .firstWhereOrNull((final remote) => remote.id == server.remoteId);
        })
        .whereType<AnnilToken>()
        .toList();
    final toUpdateIds = toUpdate.map((final e) => e.id).toList();
    final toRemove = servers
        .map((final server) {
          if (server.remoteId == null) {
            return null;
          }

          return toUpdate.where((final e) => server.remoteId == e.id).isNotEmpty
              ? null
              : server.id;
        })
        .whereType<int>()
        .toList();
    final toAdd =
        remoteList.where((final remote) => !toUpdateIds.contains(remote.id));
    await db.transaction(() async {
      // exist both in local and remote, update server info
      for (final e in toUpdate) {
        await (db.localAnnilServers.update()
              ..where((final tbl) => tbl.remoteId.equals(e.id)))
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
      await db.localAnnilServers
          .deleteWhere((final tbl) => tbl.id.isIn(toRemove));
      await db.localAnnilAlbums
          .deleteWhere((final tbl) => tbl.annilId.isIn(toRemove));
      // add new servers
      await db.batch(
        (final batch) => batch.insertAll(
          db.localAnnilServers,
          toAdd.map(
            (final e) => LocalAnnilServersCompanion.insert(
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
      final String albumId) async {
    final db = ref.read(localDatabaseProvider);
    return await db.annilToUse(albumId).get();
  }

  Future<String?> getAudioUrl({
    required final TrackIdentifier track,
    required final PreferQuality quality,
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

  Future<Uri?> getCoverUrl(
      {required final String albumId, final int? discId}) async {
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
    final db = ref.read(localDatabaseProvider);
    final albumList = <String>{};
    if (NetworkService.isOnline) {
      await Future.wait(servers.map((final server) async {
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

  bool isAlbumAvailable(final String albumId) {
    return albums.contains(albumId);
  }

  bool isTrackAvailable(final TrackIdentifier id) {
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
        .where((final entry) {
          if (entry is! Directory) {
            return false;
          }
          // return true if music file exists (any file with no extension, or flac extension)
          return entry.listSync().any((final e) =>
              e is File &&
              (p.basename(e.path).endsWith('.flac') ||
                  !p.basename(e.path).contains('.')));
        })
        .map((final entry) => p.basename(entry.path))
        .toSet();
  }

  static bool isCacheAvailable(final TrackIdentifier id) {
    final path = getAudioCachePath(id);
    return File(path).existsSync();
  }

  /// Get the available album list of an Annil server.
  Future<void> updateAlbums(final LocalAnnilServer server) async {
    final db = ref.read(localDatabaseProvider);
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
              .deleteWhere((final tbl) => tbl.annilId.equals(server.id));
          await db.batch((final batch) => batch.insertAll(db.localAnnilAlbums, [
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
              .deleteWhere((final tbl) => tbl.annilId.equals(server.id));
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

  factory PreferQuality.fromString(final String str) {
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
