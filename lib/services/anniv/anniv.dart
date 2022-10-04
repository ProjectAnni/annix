import 'dart:async';
import 'dart:convert';

import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/metadata/metadata.dart';
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
  AnnivClient? client;

  SiteUserInfo? info;

  bool get isLogin => info != null;

  AnnivService(BuildContext context) {
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

    // try to load database
    loadDatabase();
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
          final annil = Global.context.read<AnnilService>();
          final annilTokens = await client.getCredentials();
          await annil.sync(annilTokens);
        })(),
        // reload favorite list
        syncFavorite(),
        // reload playlist list
        client.getOwnedPlaylists().then(syncPlaylist),
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
    await _syncFavorite([]);
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
  Future<void> addFavorite(TrackIdentifier track) async {
    if (client != null) {
      final db = Global.context.read<LocalDatabase>();
      final MetadataService metadata =
          Provider.of<MetadataService>(Global.context, listen: false);
      final trackMetadata = await metadata.getTrack(track);

      await client?.addFavorite(track);
      await db.localFavorites.insert().insert(
            LocalFavoritesCompanion.insert(
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

  Future<void> removeFavorite(TrackIdentifier id) async {
    if (client != null) {
      final db = Provider.of<LocalDatabase>(Global.context, listen: false);
      await client?.removeFavorite(id);
      await (db.localFavorites.delete()
            ..where((f) =>
                f.albumId.equals(id.albumId) &
                f.discId.equals(id.discId) &
                f.trackId.equals(id.trackId)))
          .go();
    }
  }

  Future<bool> toggleFavorite(TrackInfoWithAlbum track) async {
    final db = Provider.of<LocalDatabase>(Global.context, listen: false);

    if (await db
        .isTrackFavorite(track.id.albumId, track.id.discId, track.id.trackId)
        .getSingle()) {
      await removeFavorite(track.id);
      return false;
    } else {
      await addFavorite(track.id);
      return true;
    }
  }

  Future<void> syncFavorite() async {
    await client?.getFavoriteList().then(_syncFavorite);
  }

  Future<void> _syncFavorite(List<TrackInfoWithAlbum> list) async {
    final db = Provider.of<LocalDatabase>(Global.context, listen: false);

    await db.transaction(() async {
      // clear favorite list
      await db.localFavorites.delete().go();
      // write new favorite list in
      await db.batch(
        (batch) => batch.insertAll(
          db.localFavorites,
          // reverse the list so that the latest favorite is at the end of the list
          list.reversed
              .map(
                (e) => LocalFavoritesCompanion.insert(
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

  //////////////////////////////// Playlist ///////////////////////////////
  Future<void> syncPlaylist(List<PlaylistInfo> list) async {
    final db = Provider.of<LocalDatabase>(Global.context, listen: false);
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
    final db = Provider.of<LocalDatabase>(Global.context, listen: false);
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

  /////////////////////////////// Database ///////////////////////////////
  Future<void> updateDatabase() async {
    await client!.downloadRepoDatabase(Global.storageRoot);
    await loadDatabase();
  }

  Future<void> loadDatabase() async {
    try {
      final metadata = Global.context.read<MetadataService>();
      final db = AnnivSqliteMetadataSource();
      await db.prepare();
      metadata.sources.insert(0, db);
    } catch (e) {
      //
    }
  }
}
