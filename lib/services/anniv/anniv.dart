import 'dart:async';
import 'dart:convert';

import 'package:annix/providers.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_source_anniv.dart';
import 'package:annix/services/metadata/metadata_source_anniv_sqlite.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/services/path.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SiteUserInfo {
  SiteInfo site;
  UserInfo user;

  SiteUserInfo({required this.site, required this.user});
}

class AnnivService extends ChangeNotifier {
  final Ref ref;

  AnnivClient? client;

  SiteUserInfo? info;

  bool get isLogin => info != null;

  AnnivService(this.ref) {
    // 1. init client
    client = AnnivClient.load(ref);

    // 2. load cached site info & user info
    _loadInfo();

    // check login status
    final network = ref.read(networkProvider);
    network.addListener(() {
      if (network.isOnline) {
        checkLogin(client);
      }
    });
    if (network.isOnline) {
      checkLogin(client);
    }

    // try to load metadata sources
    loadMetadata();
  }

  Future<void> checkLogin(final AnnivClient? client) async {
    if (client != null) {
      try {
        final result =
            await Future.wait([client.getSiteInfo(), client.getUserInfo()]);

        final site = result[0] as SiteInfo;
        final user = result[1] as UserInfo;
        info = SiteUserInfo(site: site, user: user);
        await _saveInfo();
      } catch (e) {
        if (e is DioException && e.error is AnnivError) {
          final error = e.error as AnnivError;
          if (error.status == 902002) {
            // unauthorized, logout
            this.client = null;
            await logout();
          } else {
            throw error;
          }
        } else {
          rethrow;
        }
      }
      this.client = client;

      // do not await here
      Future.wait([
        (() async {
          final annil = ref.read(annilProvider);
          final annilTokens = await client.getCredentials();
          await annil.sync(annilTokens);
        })(),
        // reload favorite list
        syncFavoriteTrack(),
        syncFavoriteAlbum(),
        // reload playlist list
        client.getPlaylistByUserId().then(syncPlaylist),
      ]);
    }
  }

  Future<void> login(
      final String url, final String email, final String password) async {
    final anniv = await AnnivClient.login(
      ref,
      url: url,
      email: email,
      password: password,
    );
    await checkLogin(anniv);
  }

  Future<void> logout() async {
    final annil = ref.read(annilProvider);

    // 1. clear anniv info
    info = null;
    await _saveInfo();

    // 2. logout anniv if necessary
    await client?.logout();

    // 3. set client to null
    client = null;

    // 4. clear annil cache
    await annil.sync([]);
    await annil.reload();

    // 5. clear favorites and remote playlists
    await _syncFavoriteTrack([]);
    await syncPlaylist([]);
  }

  void _loadInfo() {
    final preferences = ref.read(preferencesProvider);
    final site = preferences.getString('anniv_site');
    final user = preferences.getString('anniv_user');
    if (site != null && user != null) {
      info = SiteUserInfo(
        site: SiteInfo.fromJson(jsonDecode(site)),
        user: UserInfo.fromJson(jsonDecode(user)),
      );
    }
  }

  Future<void> _saveInfo() async {
    final preferences = ref.read(preferencesProvider);
    if (info != null) {
      final site = info!.site.toJson();
      final user = info!.user.toJson();
      preferences.set('anniv_site', jsonEncode(site));
      preferences.set('anniv_user', jsonEncode(user));
    } else {
      preferences.remove('anniv_site');
      preferences.remove('anniv_user');
    }
    notifyListeners();
  }

  //////////////////////////////// Favorite ///////////////////////////////
  Future<void> addFavoriteTrack(final TrackIdentifier track) async {
    if (client != null) {
      final db = ref.read(localDatabaseProvider);
      final MetadataService metadata = ref.read(metadataProvider);
      final trackMetadata = await metadata.getTrack(track);

      await client?.addFavoriteTrack(track);
      await db.localFavoriteTracks.insert().insert(
            LocalFavoriteTracksCompanion.insert(
              albumId: track.albumId,
              discId: track.discId,
              trackId: track.trackId,
              title: Value(trackMetadata?.title),
              artist: Value(trackMetadata?.artist),
              albumTitle: Value(trackMetadata?.disc.album.fullTitle),
              type: Value(trackMetadata?.type.toString() ?? 'normal'),
            ),
          );
    }
  }

  Future<void> removeFavoriteTrack(final TrackIdentifier id) async {
    if (client != null) {
      final db = ref.read(localDatabaseProvider);
      await client?.removeFavoriteTrack(id);
      await (db.localFavoriteTracks.delete()
            ..where((final f) =>
                f.albumId.equals(id.albumId) &
                f.discId.equals(id.discId) &
                f.trackId.equals(id.trackId)))
          .go();
    }
  }

  Future<bool> toggleFavoriteTrack(final TrackInfoWithAlbum track) async {
    final db = ref.read(localDatabaseProvider);

    if (await db
        .isTrackFavorite(track.id.albumId, track.id.discId, track.id.trackId)
        .getSingle()) {
      await removeFavoriteTrack(track.id);
      return false;
    } else {
      await addFavoriteTrack(track.id);
      return true;
    }
  }

  Future<void> syncFavoriteTrack() async {
    await client?.getFavoriteTracks().then(_syncFavoriteTrack);
  }

  Future<void> _syncFavoriteTrack(final List<TrackInfoWithAlbum> list) async {
    final db = ref.read(localDatabaseProvider);

    await db.transaction(() async {
      // clear favorite list
      await db.localFavoriteTracks.delete().go();
      // write new favorite list in
      await db.batch(
        (final batch) => batch.insertAll(
          db.localFavoriteTracks,
          // reverse the list so that the latest favorite is at the end of the list
          list.reversed
              .map(
                (final e) => LocalFavoriteTracksCompanion.insert(
                  albumId: e.id.albumId,
                  discId: e.id.discId,
                  trackId: e.id.trackId,
                  title: Value(e.title),
                  artist: Value(e.artist),
                  albumTitle: Value(e.albumTitle),
                  type: Value(e.type.toString()),
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Future<void> addFavoriteAlbum(final String albumId) async {
    if (client != null) {
      final db = ref.read(localDatabaseProvider);

      await client?.addFavoriteAlbum(albumId);
      await db.localFavoriteAlbums.insert().insert(
            LocalFavoriteAlbumsCompanion.insert(
              albumId: albumId,
            ),
          );
    }
  }

  Future<void> removeFavoriteAlbum(final String albumId) async {
    if (client != null) {
      final db = ref.read(localDatabaseProvider);
      await client?.removeFavoriteAlbum(albumId);
      await (db.localFavoriteAlbums.delete()
            ..where((final f) => f.albumId.equals(albumId)))
          .go();
    }
  }

  Future<bool> toggleFavoriteAlbum(final String albumId) async {
    final db = ref.read(localDatabaseProvider);

    if (await db.isAlbumFavorite(albumId).getSingle()) {
      await removeFavoriteAlbum(albumId);
      return false;
    } else {
      await addFavoriteAlbum(albumId);
      return true;
    }
  }

  Future<void> syncFavoriteAlbum() async {
    await client?.getFavoriteAlbums().then(_syncFavoriteAlbum);
  }

  Future<void> _syncFavoriteAlbum(final List<String> list) async {
    final db = ref.read(localDatabaseProvider);

    await db.transaction(() async {
      // clear favorite album list
      await db.localFavoriteAlbums.delete().go();
      // write new favorite albums
      await db.batch(
        (final batch) => batch.insertAll(
          db.localFavoriteAlbums,
          // reverse the list so that the latest favorite is at the end of the list
          list.reversed
              .map(
                (final e) => LocalFavoriteAlbumsCompanion.insert(
                  albumId: e,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  //////////////////////////////// Playlist ///////////////////////////////
  Future<void> syncPlaylist(final List<PlaylistInfo> list) async {
    final db = ref.read(localDatabaseProvider);
    final map = Map.fromEntries(list.map((final e) => MapEntry(e.id, e)));

    await db.playlist.select().asyncMap((final playlist) async {
      final isRemote = playlist.remoteId != null;
      if (isRemote) {
        final remote = map[playlist.remoteId];

        // playlist does not exist on remote, remove it
        if (remote == null) {
          db.playlist.deleteOne(playlist);
          db.playlistItem
              .deleteWhere((final tbl) => tbl.playlistId.equals(playlist.id));
        } else {
          // playlist exists on remote, compare last_modified and update it
          if (playlist.lastModified != remote.lastModified) {
            // clear items
            await db.playlistItem
                .deleteWhere((final tbl) => tbl.playlistId.equals(playlist.id));
            // update modified playlist
            await db.playlist
                .update()
                .replace(remote.toCompanion(id: Value(playlist.id)));
          }
          map.remove(remote.id);
        }
      }
    }).get();

    // the remaining playlist is new, add it
    for (final playlist in map.values) {
      db.playlist.insertOne(playlist.toCompanion());
    }
  }

  Future<List<AnnivPlaylistItem>?> getPlaylistItems(
      final PlaylistData playlist) async {
    final db = ref.read(localDatabaseProvider);
    if (!playlist.hasItems) {
      // remote playlist without track items
      // try to fetch items
      if (client == null) return null;

      try {
        final remote = await client!.getPlaylistDetail(playlist.remoteId!);

        // update tracks
        await db.batch((final batch) => batch.insertAll(
              db.playlistItem,
              remote.items
                  .asMap()
                  .entries
                  .map((final e) => e.value
                      .toCompanion(playlistId: playlist.id, order: e.key))
                  .toList(),
            ));

        // update playlist intro
        await db.playlist.update().replace(
            remote.intro.toCompanion(id: Value(playlist.id), hasItems: true));
      } catch (e) {
        // TODO: log error here
        return null;
      }
    }

    final items = await db.playlistItems(playlist.id).get();
    return items.map((final e) => AnnivPlaylistItem.fromDatabase(e)).toList();
  }

  ////////////////////////////// Statistics //////////////////////////////
  Future<void> trackPlayback(final TrackIdentifier track, final int at) async {
    final db = ref.read(localDatabaseProvider);
    await db.playbackRecords.insert().insert(PlaybackRecordsCompanion.insert(
          albumId: track.albumId,
          discId: track.discId,
          trackId: track.trackId,
          at: at,
          locked: false,
        ));

    if (client != null) {
      final records = await db.transaction(() async {
        final records = await db.playbackRecordsToSubmit().get();
        final ids = records.map((final e) => e.id).toList();
        await db.lockPlaybackRecords(ids);
        return records;
      });

      final Map<TrackIdentifier, List<int>> trackMap = {};
      for (final record in records) {
        final track = TrackIdentifier(
            albumId: record.albumId,
            discId: record.discId,
            trackId: record.trackId);
        trackMap.putIfAbsent(track, () => []);
        trackMap[track]!.add(record.at);
      }

      // swap current track map, submit to anniv server
      final tracks = trackMap.entries
          .map((final entry) =>
              SongPlayRecord(track: entry.key, at: entry.value))
          .toList();
      try {
        await client!.trackPlayback(tracks);
      } catch (_) {
        // unlock tracks for next submission
        final ids = records.map((final e) => e.id).toList();
        await db.unlockPlaybackRecords(ids);
      }
    }
  }

  /////////////////////////////// Database ///////////////////////////////
  Future<void> updateDatabase() async {
    await client!.downloadRepoDatabase(PathService.storageRoot);
    await loadMetadata();
  }

  Future<void> loadMetadata() async {
    final metadata = ref.read(metadataProvider);
    metadata.sources.insert(0, AnnivMetadataSource(this));
    try {
      final db = AnnivSqliteMetadataSource(ref);
      await db.prepare();
      metadata.sources.insert(0, db);
    } catch (_) {}
  }
}
