import 'dart:io';

import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/hash.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart' show ExtensionSnackbar, Get, Inst;
import 'package:path_provider/path_provider.dart';

class AnnivClient {
  final Dio _client;
  final CookieJar _cookieJar;

  AnnivClient({
    required String url,
    required CookieJar cookieJar,
  })  : _client = Dio(
          BaseOptions(baseUrl: url, responseType: ResponseType.json),
        )..httpClientAdapter = Http2Adapter(
            ConnectionManager(
              idleTimeout: 60000,
              onClientCreate: (_, config) {
                final SettingsController settings = Get.find();
                config.onBadCertificate = (_) {
                  return settings.skipCertificateVerification.value;
                };
              },
            ),
          ),
        _cookieJar = cookieJar {
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters.removeWhere((key, value) => value == false);
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.statusCode != 200) {
          // response status of anniv MUST be 200
          return handler.reject(DioError(
            requestOptions: response.requestOptions,
            response: response,
            type: DioErrorType.response,
          ));
        } else if (response.requestOptions.responseType == ResponseType.json) {
          final resp = response.data as Map<String, dynamic>;
          int status = resp['status'];
          if (status != 0) {
            if (status != 902000) {
              // skip [lyric not found] error
              Get.snackbar("Error", resp["message"].toString());
            }
            // business logic error code
            handler.reject(DioError(
              requestOptions: response.requestOptions,
              response: response,
              type: DioErrorType.response,
              // TODO: deserialize resp to Error object
              error: resp,
            ));
          } else {
            dynamic data = resp['data'];
            handler.resolve(Response(
              requestOptions: response.requestOptions,
              data: data,
            ));
          }
        } else {
          handler.resolve(response);
        }
      },
    ));
  }

  static Future<PersistCookieJar> _loadCookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    return PersistCookieJar(storage: FileStorage(dir.path));
  }

  static Future<AnnivClient> login({
    required String url,
    required String email,
    required String password,
  }) async {
    final client = AnnivClient(url: url, cookieJar: await _loadCookieJar());
    await client._login(email: email, password: password);
    await client._save();
    return client;
  }

  /// Load anniv url from shared preferences & load cookies
  /// If no url is found or not login, return null
  static Future<AnnivClient?> load() async {
    String? annivUrl = Global.preferences.getString('anniv_url');
    if (annivUrl == null) {
      return null;
    } else {
      return AnnivClient(url: annivUrl, cookieJar: await _loadCookieJar());
    }
  }

  /// Save anniv url to shared preferences
  Future<void> _save() async {
    await Global.preferences.setString('anniv_url', _client.options.baseUrl);
  }

  /// Get site info from Anniv server
  ///
  /// This method should be called before any other requests were sent to the server.
  /// https://book.anni.rs/06.anniv/01.info.html
  Future<SiteInfo> getSiteInfo() async {
    final response = await _client.get("/api/info");
    return SiteInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E4%BF%A1%E6%81%AF
  Future<UserInfo> getUserInfo() async {
    final response = await _client.get("/api/user/info");
    return UserInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E7%99%BB%E5%BD%95
  Future<UserInfo> _login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      "/api/user/login",
      data: {
        'email': email,
        'password': sha256(password),
      },
    );
    return UserInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E9%80%80%E5%87%BA
  Future<void> logout() async {
    // do not wait here
    _client.post("/api/user/logout");
    return this._cookieJar.deleteAll();
  }

  /// https://book.anni.rs/06.anniv/04.credential.html#%E8%8E%B7%E5%8F%96-token
  Future<List<AnnilToken>> getCredentials() async {
    final response = await _client.get("/api/credential");
    return (response.data as List<dynamic>)
        .map((e) => AnnilToken.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/08.meta.html#%E4%B8%93%E8%BE%91%E4%BF%A1%E6%81%AF
  Future<Map<String, Album>> getAlbumMetadata(List<String> albums) async {
    final response =
        await _client.get('/api/meta/album', queryParameters: {'id[]': albums});
    Map<String, dynamic> responseAlbums = response.data;
    return responseAlbums
        .map((key, value) => MapEntry(key, value as Map<String, dynamic>))
        .map(
          (albumId, album) => MapEntry(
            albumId,
            AlbumInfo.fromJson(album).toAlbum(),
          ),
        );
  }

  // https://book.anni.rs/06.anniv/09.search.html
  Future<SearchResult> search(
    String keyword, {
    bool searchAlbums = false,
    bool searchTracks = false,
    bool searchPlaylists = false,
  }) async {
    final response = await _client.get('/api/search', queryParameters: {
      'keyword': keyword,
      'search_albums': searchAlbums,
      'search_tracks': searchTracks,
      'search_playlists': searchPlaylists,
    });
    return SearchResult.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E8%8E%B7%E5%8F%96%E5%96%9C%E6%AC%A2%E5%88%97%E8%A1%A8
  Future<List<TrackInfoWithAlbum>> getFavoriteList() async {
    final response = await _client.get('/api/favorite/music');
    return (response.data as List<dynamic>)
        .map((e) => TrackInfoWithAlbum.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E6%B7%BB%E5%8A%A0%E5%8D%95%E6%9B%B2
  Future<void> addFavorite(String id) async {
    TrackIdentifier track = TrackIdentifier.fromSlashSplitedString(id);
    await _client.put('/api/favorite/music', data: {
      'album_id': track.albumId,
      'disc_id': track.discId,
      'track_id': track.trackId,
    });
  }

  Future<void> removeFavorite(String id) async {
    TrackIdentifier track = TrackIdentifier.fromSlashSplitedString(id);
    await _client.delete('/api/favorite/music', data: {
      'album_id': track.albumId,
      'disc_id': track.discId,
      'track_id': track.trackId,
    });
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E8%8E%B7%E5%8F%96%E6%8C%87%E5%AE%9A%E7%94%A8%E6%88%B7%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<List<PlaylistInfo>> getOwnedPlaylists([String? userId]) async {
    // TODO: userId
    final response = await _client.get('/api/playlists');
    return (response.data as List<dynamic>)
        .map((e) => PlaylistInfo.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E8%8E%B7%E5%8F%96%E6%8C%87%E5%AE%9A%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> getPlaylistDetail(String id) async {
    final response = await _client.get('/api/playlist?id=$id');
    return Playlist.fromJson(response.data);
  }

  Future<LyricResponse?> getLyric(String id) async {
    TrackIdentifier track = TrackIdentifier.fromSlashSplitedString(id);
    try {
      final response = await _client.get('/api/lyric', queryParameters: {
        'album_id': track.albumId,
        'disc_id': track.discId,
        'track_id': track.trackId,
      });
      return LyricResponse.fromJson(response.data);
    } on DioError catch (e) {
      // no available lyric found
      // TODO: handle error correctly
      if (e.error["status"] == 902000) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  Future<RepoDatabaseDecsription?> getRepoDatabaseDescription() async {
    try {
      final response =
          await _client.get<RepoDatabaseDecsription>('/api/meta/db/repo.json');
      return response.data;
    } catch (e) {
      FLog.error(text: e.toString(), exception: e);
      return null;
    }
  }

  Future<void> getRepoDatabase(String savePath) async {
    await _client.download('/api/meta/db/repo.db', savePath + ".downloading");
    final file = File(savePath + ".downloading");
    await file.rename(savePath);
  }
}
