import 'dart:async';
import 'dart:convert';

import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_source_anniv.dart';
import 'package:annix/services/metadata/metadata_source_anniv_sqlite.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/network/network.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SiteUserInfo {
  SiteInfo site;
  UserInfo user;

  SiteUserInfo({required this.site, required this.user});
}

class AnnivService extends ChangeNotifier {
  BuildContext context;

  AnnivClient? client;

  SiteUserInfo? info;

  bool get isLogin => info != null;

  AnnivService(this.context) {
    // 1. init client
    client = AnnivClient.load();

    // 2. load cached site info & user info
    _loadInfo();

    // check login status
    final network = context.read<NetworkService>();
    network.addListener(() {
      if (NetworkService.isOnline) {
        checkLogin(client);
      }
    });
    if (NetworkService.isOnline) {
      checkLogin(client);
    }

    // try to load metadata sources
    loadMetadata();
  }

  Future<void> checkLogin(AnnivClient? client) async {
    if (client != null) {
      try {
        final result =
            await Future.wait([client.getSiteInfo(), client.getUserInfo()]);

        final site = result[0] as SiteInfo;
        final user = result[1] as UserInfo;
        info = SiteUserInfo(site: site, user: user);
        await _saveInfo();
      } catch (e) {
        if (e is DioError && e.error is AnnivError) {
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
          final annil = context.read<AnnilService>();
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

  Future<void> login(String url, String email, String password) async {
    final anniv =
        await AnnivClient.login(url: url, email: email, password: password);
    await checkLogin(anniv);
  }

  Future<void> logout() async {
    final annil = Global.context.read<AnnilService>();

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
    final site = Global.preferences.getString('anniv_site');
    final user = Global.preferences.getString('anniv_user');
    if (site != null && user != null) {
      info = SiteUserInfo(
        site: SiteInfo.fromJson(jsonDecode(site)),
        user: UserInfo.fromJson(jsonDecode(user)),
      );
    }
  }

  Future<void> _saveInfo() async {
    if (info != null) {
      final site = info!.site.toJson();
      final user = info!.user.toJson();
      await Global.preferences.setString('anniv_site', jsonEncode(site));
      await Global.preferences.setString('anniv_user', jsonEncode(user));
    } else {
      await Global.preferences.remove('anniv_site');
      await Global.preferences.remove('anniv_user');
    }
    notifyListeners();
  }

  //////////////////////////////// Favorite ///////////////////////////////
  Future<void> addFavoriteTrack(TrackIdentifier track) async {
    if (client != null) {
      final db = Global.context.read<LocalDatabase>();
      final MetadataService metadata = Global.context.read<MetadataService>();
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

  Future<void> removeFavoriteTrack(TrackIdentifier id) async {
    if (client != null) {
      final db = Global.context.read<LocalDatabase>();
      await client?.removeFavoriteTrack(id);
      await (db.localFavoriteTracks.delete()
            ..where((f) =>
                f.albumId.equals(id.albumId) &
                f.discId.equals(id.discId) &
                f.trackId.equals(id.trackId)))
          .go();
    }
  }

  Future<bool> toggleFavoriteTrack(TrackInfoWithAlbum track) async {
    final db = Global.context.read<LocalDatabase>();

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

  Future<void> _syncFavoriteTrack(List<TrackInfoWithAlbum> list) async {
    final db = context.read<LocalDatabase>();

    await db.transaction(() async {
      // clear favorite list
      await db.localFavoriteTracks.delete().go();
      // write new favorite list in
      await db.batch(
        (batch) => batch.insertAll(
          db.localFavoriteTracks,
          // reverse the list so that the latest favorite is at the end of the list
          list.reversed
              .map(
                (e) => LocalFavoriteTracksCompanion.insert(
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

  Future<void> addFavoriteAlbum(String albumId) async {
    if (client != null) {
      final db = Global.context.read<LocalDatabase>();

      await client?.addFavoriteAlbum(albumId);
      await db.localFavoriteAlbums.insert().insert(
            LocalFavoriteAlbumsCompanion.insert(
              albumId: albumId,
            ),
          );
    }
  }

  Future<void> removeFavoriteAlbum(String albumId) async {
    if (client != null) {
      final db = Global.context.read<LocalDatabase>();
      await client?.removeFavoriteAlbum(albumId);
      await (db.localFavoriteAlbums.delete()
            ..where((f) => f.albumId.equals(albumId)))
          .go();
    }
  }

  Future<bool> toggleFavoriteAlbum(String albumId) async {
    final db = Global.context.read<LocalDatabase>();

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

  Future<void> _syncFavoriteAlbum(List<String> list) async {
    final db = context.read<LocalDatabase>();

    await db.transaction(() async {
      // clear favorite album list
      await db.localFavoriteAlbums.delete().go();
      // write new favorite albums
      await db.batch(
        (batch) => batch.insertAll(
          db.localFavoriteAlbums,
          // reverse the list so that the latest favorite is at the end of the list
          list.reversed
              .map(
                (e) => LocalFavoriteAlbumsCompanion.insert(
                  albumId: e,
                ),
              )
              .toList(),
        ),
      );
    });
  }

  //////////////////////////////// Playlist ///////////////////////////////
  Future<void> syncPlaylist(List<PlaylistInfo> list) async {
    final db = Global.context.read<LocalDatabase>();
    final map = Map.fromEntries(list.map((e) => MapEntry(e.id, e)));

    await db.playlist.select().asyncMap((playlist) async {
      final isRemote = playlist.remoteId != null;
      if (isRemote) {
        final remote = map[playlist.remoteId];

        // playlist does not exist on remote, remove it
        if (remote == null) {
          db.playlist.deleteOne(playlist);
          db.playlistItem
              .deleteWhere((tbl) => tbl.playlistId.equals(playlist.id));
        } else {
          // playlist exists on remote, compare last_modified and update it
          if (playlist.lastModified != remote.lastModified) {
            // clear items
            await db.playlistItem
                .deleteWhere((tbl) => tbl.playlistId.equals(playlist.id));
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
      PlaylistData playlist) async {
    final db = Global.context.read<LocalDatabase>();
    if (!playlist.hasItems) {
      // remote playlist without track items
      // try to fetch items
      if (client == null) return null;

      try {
        final remote = await client!.getPlaylistDetail(playlist.remoteId!);

        // update tracks
        await db.batch((batch) => batch.insertAll(
              db.playlistItem,
              remote.items
                  .asMap()
                  .entries
                  .map((e) => e.value
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
    return items.map((e) => AnnivPlaylistItem.fromDatabase(e)).toList();
  }

  ////////////////////////////// Statistics //////////////////////////////
  Future<void> trackPlayback(TrackIdentifier track, int at) async {
    final db = Global.context.read<LocalDatabase>();
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
        final ids = records.map((e) => e.id).toList();
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
          .map((entry) => SongPlayRecord(track: entry.key, at: entry.value))
          .toList();
      try {
        await client!.trackPlayback(tracks);
      } catch (_) {
        // unlock tracks for next submission
        final ids = records.map((e) => e.id).toList();
        await db.unlockPlaybackRecords(ids);
      }
    }
  }

  /////////////////////////////// Database ///////////////////////////////
  Future<void> updateDatabase() async {
    await client!.downloadRepoDatabase(Global.storageRoot);
    await loadMetadata();
  }

  Future<void> loadMetadata() async {
    final metadata = context.read<MetadataService>();
    metadata.sources.insert(0, AnnivMetadataSource(this));
    try {
      final db = AnnivSqliteMetadataSource();
      await db.prepare();
      metadata.sources.insert(0, db);
    } catch (_) {}
  }
}
