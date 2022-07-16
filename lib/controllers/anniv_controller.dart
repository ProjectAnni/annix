import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/network_controller.dart';
import 'package:annix/metadata/metadata_source_anniv.dart';
import 'package:annix/metadata/metadata_source_sqlite.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/global.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

class SiteUserInfo {
  SiteInfo site;
  UserInfo user;

  SiteUserInfo({required this.site, required this.user});
}

class AnnivController extends GetxController {
  AnnilController _annil = Get.find();
  NetworkController _network = Get.find();

  AnnivClient? client;

  Rxn<SiteUserInfo> info = Rxn(null);
  Rx<bool> isLogin = false.obs;

  static Future<AnnivController> init() async {
    // 1. init client
    final controller = AnnivController._(await AnnivClient.load());

    // 2. load cached site info & user info
    controller._loadInfo();

    // 3. load favorites
    controller._loadFavorites();

    // 4. metadata
    try {
      await controller.loadDatabase();
    } finally {}

    return controller;
  }

  AnnivController._(this.client);

  @override
  void onInit() {
    super.onInit();
    this.isLogin.bindStream(this.info.stream.map((user) => user != null));

    // check login status
    if (_network.isOnline.value) {
      checkLogin(this.client);
    }
    _network.isOnline.listen((isOnline) {
      if (isOnline) {
        checkLogin(this.client);
      }
    });
  }

  Future<void> checkLogin(AnnivClient? client) async {
    if (client != null) {
      try {
        var site;
        var user;
        await Future.wait([
          client.getSiteInfo().then((s) => site = s),
          client.getUserInfo().then((u) => user = u),
        ]);
        this.info.value = SiteUserInfo(site: site, user: user);
        await this._saveInfo();
      } catch (e) {
        if (e is DioError &&
            e.response?.statusCode == 200 &&
            e.error["status"] == 902002) {
          // 鉴权失败，退出登录
          await this.logout();
        } else {
          rethrow;
        }
      }
      this.client = client;

      if (!Global.metadataSource.isCompleted) {
        Global.metadataSource.complete(AnnivMetadataSource(client));
      }

      await Future.wait([
        // reload annil client
        (() async {
          final annilTokens = await client.getCredentials();
          _annil.syncWithRemote(annilTokens);
          _annil.refresh();
        })(),
        // reload favorite list
        this.syncFavorite(),
        // reload playlist list
        this.syncPlaylist(),
        // reload tags
        this.syncTags(),
      ]);
    }
  }

  Future<void> login(String url, String email, String password) async {
    final anniv =
        await AnnivClient.login(url: url, email: email, password: password);
    await checkLogin(anniv);
  }

  Future<void> logout() async {
    await this.client?.logout();
    this.info.value = null;
    await this._saveInfo();
  }

  void _loadInfo() {
    final site = Global.preferences.getString("anniv_site");
    final user = Global.preferences.getString("anniv_user");
    if (site != null && user != null) {
      this.info.value = SiteUserInfo(
        site: SiteInfo.fromJson(jsonDecode(site)),
        user: UserInfo.fromJson(jsonDecode(user)),
      );
    }
  }

  Future<void> _saveInfo() async {
    if (this.info.value != null) {
      final site = this.info.value!.site.toJson();
      final user = this.info.value!.user.toJson();
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
    if (this.client != null) {
      final trackMetadata = await (await Global.metadataSource.future).getTrack(
          albumId: track.albumId, discId: track.discId, trackId: track.trackId);
      favorites[track.toSlashedString()] = TrackInfoWithAlbum(
        track: track,
        title: trackMetadata!.title,
        artist: trackMetadata.artist,
        albumTitle: trackMetadata.disc.album.title,
        type: trackMetadata.type,
      );
      try {
        await this.client?.addFavorite(track);
        await _saveFavorites();
      } catch (e) {
        favorites.remove(track.toSlashedString());
        throw e;
      }
    }
  }

  Future<void> removeFavorite(TrackIdentifier id) async {
    if (this.client != null) {
      final got = favorites.remove(id.toSlashedString());
      try {
        await this.client?.removeFavorite(id);
        await _saveFavorites();
      } catch (e) {
        if (got != null) {
          favorites[id.toSlashedString()] = got;
        }
        rethrow;
      }
    }
  }

  Future<void> toggleFavorite(TrackIdentifier id) async {
    if (favorites.containsKey(id.toSlashedString())) {
      await this.removeFavorite(id);
    } else {
      await this.addFavorite(id);
    }
  }

  Future<void> syncFavorite() async {
    if (this.client != null) {
      final list = await this.client!.getFavoriteList();
      // reverse favorite map here
      final map = Map.fromEntries(
          list.reversed.map((e) => MapEntry(e.track.toSlashedString(), e)));
      favorites.value = map;
      await _saveFavorites();
    }
  }

  //////////////////////////////// Playlist ///////////////////////////////
  RxMap<String, PlaylistInfo> playlists = RxMap();
  Map<String, Playlist> playlistDetail = Map();

  Future<void> syncPlaylist() async {
    if (this.client != null) {
      final list = await this.client!.getOwnedPlaylists();
      final map = Map.fromEntries(list.map((e) => MapEntry(e.id, e)));
      playlists.value = map;
    }
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

      if (Global.metadataSource.isCompleted) {
        Global.metadataSource = Completer();
      }
      Global.metadataSource.complete(db);
    }
  }

  /////////////////////////////// Tags ///////////////////////////////
  RxMap<String, TagInfo> tags = RxMap();
  RxMap<String, List<String>> tagsRelationship = RxMap();
  Future<void> syncTags() async {
    if (this.client != null) {
      final newTags = await this.client!.getTags();
      tags.value = Map.fromEntries(newTags.map((e) => MapEntry(e.name, e)));

      final newTagsRelation = await this.client!.getTagsRelationship();
      tagsRelationship.value = newTagsRelation;
    }
  }
}
