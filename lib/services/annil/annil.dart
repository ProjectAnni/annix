import 'dart:async';
import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/path.dart';
import 'package:annix/utils/redirect_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:collection/collection.dart';

class AnnilService extends ChangeNotifier {
  final Ref ref;
  final Dio client = Dio();

  List<LocalAnnilServer> servers = [];
  Map<int, String?> etags = {};
  List<String> albums = [];

  // TODO: move annil logic to rust and remove the workaround
  Completer<void> syncedToRust = Completer();

  AnnilService(this.ref) {
    client.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (final cert, final host, final port) =>
            ref.read(settingsProvider).skipCertificateVerification.value;
        return client;
      },
      validateCertificate: (final cert, final host, final port) => true,
    );

    client.interceptors.add(RetryInterceptor(
      dio: client,
      logPrint: (final text) => Logger.error(text),
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3),
      ],
    ));

    client.interceptors.add(RedirectInterceptor(client));

    final db = ref.read(localDatabaseProvider);
    final player = ref.read(playbackProvider).player;
    db.localAnnilCaches.select().get().then((final value) {
      etags.addAll(
          Map.fromEntries(value.map((final e) => MapEntry(e.annilId, e.etag))));
    });
    final annilServersStream = db.sortedAnnilServers().watch();
    annilServersStream.listen((final event) async {
      if (!listEquals(event, servers)) {
        servers = event;

        // TODO: move annil logic to rust and remove the workaround
        if (!syncedToRust.isCompleted) {
          await player.clearProvider();
          for (final server in servers) {
            await player.addProvider(
              url: server.url,
              auth: server.token,
              priority: server.priority,
            );
          }
          if (!syncedToRust.isCompleted) {
            syncedToRust.complete();
          }
        }

        unawaited(reload());
      }
    });

    final network = ref.read(networkProvider);
    network.addListener(() => reload());

    reload();
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
    final player = ref.read(playbackProvider).player;
    // TODO: move annil logic to rust and remove the workaround
    await player.clearProvider();
    for (final server in remoteList) {
      await player.addProvider(
        url: server.url,
        auth: server.token,
        priority: server.priority,
      );
    }
    if (!syncedToRust.isCompleted) {
      syncedToRust.complete();
    }

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
    final settings = ref.read(settingsProvider);
    if (servers.isNotEmpty) {
      for (final server in servers) {
        if (etags[server.id] != null) {
          return '${server.url}/${track.albumId}/${track.discId}/${track.trackId}?auth=${server.token}&quality=$quality&opus=${settings.experimentalOpus.value ? "true" : "false"}';
        }
      }
    }
    return null;
  }

  Future<Uri?> getCoverUrl(
      {required final String albumId, final int? discId}) async {
    if (ref.read(isOnlineProvider)) {
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
    if (ref.read(isOnlineProvider)) {
      await Future.wait(servers.map((final server) async {
        try {
          await updateAlbums(server);
        } catch (e) {
          Logger.warn(
            'Failed to refresh annil ${server.name}',
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
        (ref.read(isOnlineProvider) && albums.contains(id.albumId));
  }

  static Future<Set<String>> getCachedAlbums() async {
    final root = Directory(audioCachePath());
    if (!root.existsSync()) {
      return {};
    }

    return root
        .list()
        .where((final entry) {
          if (entry is! Directory) {
            return false;
          }
          // return true if music file exists (any file with no extension)
          return entry
              .listSync()
              .any((final e) => e is File && !p.basename(e.path).contains('.'));
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

    // update timestamp
    await db.updateAnnilETag(
      server.id,
      etag,
      DateTime.timestamp().millisecondsSinceEpoch,
    );

    try {
      final response = await client.getUri(
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
      Logger.debug(
        'Annil cache MISSED, old etag: $etag, new etag: $newETag',
      );
      if (etag != newETag) {
        etags[server.id] = newETag;
        await db.transaction(() async {
          await db.updateAnnilETag(
            server.id,
            newETag,
            DateTime.timestamp().millisecondsSinceEpoch,
          );
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 304) {
        Logger.trace('Annil cache HIT, etag: $etag');
      } else {
        etags.remove(server.id);
        await db.transaction(() async {
          await db.updateAnnilETag(server.id, null, null);
          await db.localAnnilAlbums
              .deleteWhere((final tbl) => tbl.annilId.equals(server.id));
        });
        rethrow;
      }
    }

    notifyListeners();
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
