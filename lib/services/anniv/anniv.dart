import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:annix/services/local/database.dart' hide Playlist, PlaylistItem;
import 'package:annix/services/metadata/metadata_source_anniv.dart';
import 'package:annix/services/metadata/metadata_source_offline.dart';
import 'package:annix/services/metadata/metadata_source_sqlite.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/anniv/anniv_client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/network.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class SiteUserInfo {
  SiteInfo site;
  UserInfo user;

  SiteUserInfo({required this.site, required this.user});
}

class AnnivService {
  AnnivClient? client;

  Rxn<SiteUserInfo> info = Rxn(null);
  Rx<bool> isLogin = false.obs;

  AnnivService(BuildContext context) {
    // 1. init client
    client = AnnivClient.load();

    // 2. load cached site info & user info
    _loadInfo();

    // 3. load favorites
    _loadFavorites();

    isLogin.bindStream(info.stream.map((user) => user != null));

    // check login status
    final network = Provider.of<NetworkService>(context, listen: false);
    if (NetworkService.isOnline) {
      checkLogin(client);
    }
    network.addListener(() {
      if (NetworkService.isOnline) {
        checkLogin(client);
      }
    });

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
        info.value = SiteUserInfo(site: site, user: user);
        await _saveInfo();
      } catch (e) {
        if (e is DioError &&
            e.response?.statusCode == 200 &&
            e.error["status"] == 902002) {
          // 鉴权失败，退出登录
          await logout();
          this.client = null;
          return;
        } else {
          rethrow;
        }
      }
      this.client = client;

      if (Global.metadataSource is OfflineMetadataSource) {
        Global.metadataSource = AnnivMetadataSource(client);
      }

      await Future.wait([
        // FIXME: reload annil client
        // (() async {
        //   final annilTokens = await client.getCredentials();
        //   _annil.syncWithRemote(annilTokens);
        //   _annil.reloadClients();
        // })(),
        // reload favorite list
        syncFavorite(),
        // reload playlist list
        syncPlaylist(),
      ]);
    }
  }

  Future<void> login(String url, String email, String password) async {
    final anniv =
        await AnnivClient.login(url: url, email: email, password: password);
    await checkLogin(anniv);
  }

  Future<void> logout() async {
    info.value = null;
    await _saveInfo();

    await client?.logout();
  }

  void _loadInfo() {
    final site = Global.preferences.getString("anniv_site");
    final user = Global.preferences.getString("anniv_user");
    if (site != null && user != null) {
      info.value = SiteUserInfo(
        site: SiteInfo.fromJson(jsonDecode(site)),
        user: UserInfo.fromJson(jsonDecode(user)),
      );
    }
  }

  Future<void> _saveInfo() async {
    if (info.value != null) {
      final site = info.value!.site.toJson();
      final user = info.value!.user.toJson();
      await Global.preferences.setString("anniv_site", jsonEncode(site));
      await Global.preferences.setString("anniv_user", jsonEncode(user));
    } else {
      await Global.preferences.remove("anniv_site");
      await Global.preferences.remove("anniv_user");
    }
  }

  //////////////////////////////// Favorite ///////////////////////////////
  RxMap<String, TrackInfoWithAlbum> favorites = RxMap();

  void _loadFavorites() async {
    final favoritesLoaded = Global.preferences.getString("anniv_favorites");
    if (favoritesLoaded != null) {
      final favoriteMap = (jsonDecode(favoritesLoaded) as List<dynamic>)
          .map((e) => TrackInfoWithAlbum.fromJson(e))
          .map((e) => MapEntry(e.track.toSlashedString(), e));
      favorites.value = Map.fromEntries(favoriteMap);
    }
  }

  Future<void> _saveFavorites() async {
    await Global.preferences
        .setString("anniv_favorites", jsonEncode(favorites.values.toList()));
  }

  Future<void> addFavorite(TrackIdentifier track) async {
    if (client != null) {
      final trackMetadata = await Global.metadataSource.getTrack(
          albumId: track.albumId, discId: track.discId, trackId: track.trackId);
      favorites[track.toSlashedString()] = TrackInfoWithAlbum(
        track: track,
        title: trackMetadata!.title,
        artist: trackMetadata.artist,
        albumTitle: trackMetadata.disc.album.fullTitle,
        type: trackMetadata.type,
      );
      try {
        await client?.addFavorite(track);
        await _saveFavorites();
      } catch (e) {
        favorites.remove(track.toSlashedString());
        rethrow;
      }
    }
  }

  Future<void> removeFavorite(TrackIdentifier id) async {
    if (client != null) {
      final got = favorites.remove(id.toSlashedString());
      try {
        await client?.removeFavorite(id);
        await _saveFavorites();
      } catch (e) {
        if (got != null) {
          favorites[id.toSlashedString()] = got;
        }
        rethrow;
      }
    }
  }

  Future<bool> toggleFavorite(TrackIdentifier id) async {
    if (favorites.containsKey(id.toSlashedString())) {
      await removeFavorite(id);
      return false;
    } else {
      await addFavorite(id);
      return true;
    }
  }

  Future<void> syncFavorite() async {
    if (client != null) {
      final list = await client!.getFavoriteList();
      // reverse favorite map here
      final map = Map.fromEntries(
          list.reversed.map((e) => MapEntry(e.track.toSlashedString(), e)));
      favorites.value = map;
      await _saveFavorites();
    }
  }

  //////////////////////////////// Playlist ///////////////////////////////
  Future<void> syncPlaylist() async {
    if (client != null) {
      final db = Provider.of<LocalDatabase>(Global.context, listen: false);

      final list = await client!.getOwnedPlaylists();
      final map = Map.fromEntries(list.map((e) => MapEntry(e.id, e)));

      // TODO: remove deduplicate
      final deduplicate = <String>[];
      await db.playlist.select().asyncMap((playlist) async {
        final isRemote = playlist.remoteId != null;
        if (isRemote) {
          final remote = map[playlist.remoteId];

          // playlist does not exist on remote, remove it
          if (remote == null || deduplicate.contains(remote.id)) {
            db.playlist.deleteOne(playlist);
            db.playlistItem
                .deleteWhere((tbl) => tbl.playlistId.equals(playlist.id));
          } else {
            // playlist exists on remote, compare last_modified and update it
            // FIXME: replace -1 with map[id].lastModified
            if (playlist.lastModified != -1) {
              // update modified playlist
              await db.playlist
                  .update()
                  .replace(remote.toCompanion(id: Value(playlist.id)));
            }
            deduplicate.add(remote.id);
            map.remove(remote.id);
          }
        }
      }).get();

      // the remaining playlist is new, add it
      for (final playlist in map.values) {
        db.playlist.insertOne(playlist.toCompanion());
      }
    }
  }

  Future<List<PlaylistItem>?> getPlaylistItems(PlaylistData playlist) async {
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
    return items.map((e) => PlaylistItem.fromDatabase(e)).toList();
  }

  /////////////////////////////// Database ///////////////////////////////
  String get _databasePath => p.join(Global.storageRoot, 'repo.db');

  Future<void> updateDatabase() async {
    await client!.getRepoDatabase(_databasePath);
    await loadDatabase();
  }

  Future<void> loadDatabase() async {
    if (File(_databasePath).existsSync()) {
      final db = SqliteMetadataSource(_databasePath);
      await db.prepare();

      Global.metadataSource = db;
    }
  }
}
