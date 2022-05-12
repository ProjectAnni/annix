import 'dart:convert';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/offline_controller.dart';
import 'package:annix/metadata/metadata_source_anniv.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/global.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

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

  Future<void> init() async {
    // 1. init client
    this.client = await AnnivClient.loadFromLocal();

    // 2. load cached site info & user info
    this._loadInfo();

    // 3. update if online
    if (_network.isOnline.value) {
      await checkLogin(this.client);
    }

    // 4. metadata
    if (this.client != null && Global.metadataSource == null) {
      Global.metadataSource = AnnivMetadataSource(this.client!);
    }
  }

  @override
  void onInit() {
    super.onInit();
    this.isLogin.bindStream(this.info.stream.map((user) => user != null));
  }

  Future<void> checkLogin(AnnivClient? anniv) async {
    if (anniv != null) {
      try {
        final site = await anniv.getSiteInfo();
        final user = await anniv.getUserInfo();
        this.info.value = SiteUserInfo(site: site, user: user);
        await this._saveInfo();
      } catch (e) {
        if (e is DioError &&
            e.response?.statusCode == 200 &&
            e.error["status"] == 902002) {
          // 鉴权失败，退出登录
          this.info.value = null;
          await this._saveInfo();
        } else {
          rethrow;
        }
      }

      // reload annil client
      final annilTokens = await anniv.getCredentials();
      _annil.syncWithRemote(annilTokens);
      await _annil.refresh();

      this.client = anniv;
    }
  }

  Future<void> login(String url, String email, String password) async {
    final anniv =
        await AnnivClient.login(url: url, email: email, password: password);
    await checkLogin(anniv);
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

  Future<void> addFavorite(String id) async {
    if (this.client != null) {
      final track = TrackIdentifier.fromSlashSplitedString(id);
      final trackMetadata = await Global.metadataSource!.getTrack(
          albumId: track.albumId, discId: track.discId, trackId: track.trackId);
      favorites[id] = TrackInfoWithAlbum(
        track: track,
        title: trackMetadata!.title,
        artist: trackMetadata.artist,
        type: trackMetadata.type,
      );
      try {
        await this.client?.addFavorite(id);
      } catch (e) {
        favorites.remove(id);
        rethrow;
      }
    }
  }

  Future<void> removeFavorite(String id) async {
    if (this.client != null) {
      final got = favorites.remove(id);
      try {
        await this.client?.removeFavorite(id);
      } catch (e) {
        if (got != null) {
          favorites[id] = got;
        }
        rethrow;
      }
    }
  }

  Future<void> toggleFavorite(String id) async {
    if (favorites.containsKey(id)) {
      await this.removeFavorite(id);
    } else {
      await this.addFavorite(id);
    }
  }

  Future<void> syncFavorite() async {
    if (this.client != null) {
      final list = await this.client!.getFavoriteList();
      final map = Map<String, TrackInfoWithAlbum>();
      for (final track in list) {
        map[track.track.toSlashedString()] = track;
      }
      favorites.value = map;
    }
  }
}
