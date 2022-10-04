import 'dart:io';

import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/global.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/network/http_plus_adapter.dart';
import 'package:annix/utils/hash.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'package:f_logs/f_logs.dart';
import 'package:path/path.dart' as p;

class AnnivError extends Error {
  final int status;
  final String message;

  AnnivError({required this.status, required this.message});

  @override
  String toString() {
    return 'AnnivError: $message';
  }
}

class AnnivClient {
  final Dio _client;
  final CookieJar _cookieJar;

  AnnivClient({required String url, required CookieJar cookieJar})
      : _client = Dio(
          BaseOptions(baseUrl: url, responseType: ResponseType.json),
        )..httpClientAdapter = createHttpPlusAdapter(),
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
          final status = resp['status'] as int;
          if (status != 0) {
            final error = AnnivError(
              status: status,
              message: resp['message'].toString(),
            );
            if (status != 902000) {
              // skip logging [lyric not found] error
              // TODO: show error to user
              FLog.error(text: resp['message'].toString(), exception: error);
            }
            // business logic error code
            handler.reject(DioError(
              requestOptions: response.requestOptions,
              response: response,
              type: DioErrorType.response,
              error: error,
            ));
          } else {
            final dynamic data = resp['data'];
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

  static PersistCookieJar _loadCookieJar() {
    return PersistCookieJar(storage: FileStorage(Global.dataRoot));
  }

  static Future<AnnivClient> login({
    required String url,
    required String email,
    required String password,
  }) async {
    final client = AnnivClient(url: url, cookieJar: _loadCookieJar());
    await client._login(email: email, password: password);
    await client._save();
    return client;
  }

  /// Load anniv url from shared preferences & load cookies
  /// If no url is found or not login, return null
  static AnnivClient? load() {
    final annivUrl = Global.preferences.getString('anniv_url');
    if (annivUrl == null) {
      return null;
    } else {
      return AnnivClient(url: annivUrl, cookieJar: _loadCookieJar());
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
    final response = await _client.get('/api/info');
    return SiteInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E4%BF%A1%E6%81%AF
  Future<UserInfo> getUserInfo() async {
    final response = await _client.get('/api/user/info');
    return UserInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E7%99%BB%E5%BD%95
  Future<UserInfo> _login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/api/user/login',
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
    _client.post('/api/user/logout').catchError((err) {});
    _cookieJar.deleteAll();
    await Global.preferences.remove('anniv_url');
    return;
  }

  /// https://book.anni.rs/06.anniv/04.credential.html#%E8%8E%B7%E5%8F%96-token
  Future<List<AnnilToken>> getCredentials() async {
    final response = await _client.get('/api/credential');
    return (response.data as List<dynamic>)
        .map((e) => AnnilToken.fromJson(e))
        .toList();
  }

  /// https://book.anni.rs/06.anniv/04.credential.html#%E4%BF%AE%E6%94%B9-token
  Future<void> updateCredential(
    String id, {
    String? name,
    String? url,
    String? token,
    int? priority,
  }) async {
    await _client.patch('/api/credential', data: {
      'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (token != null) 'token': token,
      if (priority != null) 'priority': priority,
    });
  }

  // https://book.anni.rs/06.anniv/08.meta.html#%E4%B8%93%E8%BE%91%E4%BF%A1%E6%81%AF
  Future<Map<String, Album>> getAlbumMetadata(List<String> albums) async {
    final response =
        await _client.get('/api/meta/album', queryParameters: {'id[]': albums});
    final Map<String, dynamic> responseAlbums = response.data;
    return responseAlbums
        .map((key, value) => MapEntry(key, value as Map<String, dynamic>))
        .map(
          (albumId, album) => MapEntry(
            albumId,
            Album.fromJson(album),
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
  Future<void> addFavorite(TrackIdentifier track) async {
    await _client.put('/api/favorite/music', data: {
      'album_id': track.albumId,
      'disc_id': track.discId,
      'track_id': track.trackId,
    });
  }

  Future<void> removeFavorite(TrackIdentifier track) async {
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
    final response =
        await _client.get('/api/playlist', queryParameters: {'id': id});
    return Playlist.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E5%88%9B%E5%BB%BA%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> createPlaylist({
    required String name,
    required String description,
    bool public = true,
    DiscIdentifier? cover,
    List<AnnivPlaylistItem> items = const [],
  }) async {
    final response = await _client.put('/api/playlist', data: {
      'name': name,
      'description': description,
      'is_public': public,
      'cover': cover?.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
    });
    return Playlist.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E4%BF%AE%E6%94%B9%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> updatePlaylistInfo({
    required String playlistId,
    required PatchedPlaylistInfo info,
  }) async {
    final response = await _client.patch('/api/playlist', data: {
      'id': playlistId,
      'command': 'info',
      'payload': info.toJson(),
    });
    return Playlist.fromJson(response.data);
  }

  Future<LyricResponse?> getLyric(TrackIdentifier track) async {
    try {
      final response = await _client.get('/api/lyric', queryParameters: {
        'album_id': track.albumId,
        'disc_id': track.discId,
        'track_id': track.trackId,
      });
      return LyricResponse.fromJson(response.data);
    } on DioError catch (e) {
      // no available lyric found
      if (e.error is AnnivError) {
        final error = e.error as AnnivError;
        if (error.status == 902000) {
          return null;
        }
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<RepoDatabaseDescription> getRepoDatabaseDescription() async {
    final response =
        await _client.get<RepoDatabaseDescription>('/api/meta/db/repo.json');
    return response.data!;
  }

  Future<void> downloadRepoDatabase(String saveRoot) async {
    // 1. download json
    final jsonPath = p.join(saveRoot, 'repo.json');
    await _client.download('/api/meta/db/repo.json', '$jsonPath.downloading');
    final jsonFile = File('$jsonPath.downloading');

    // 2. download db
    final dbPath = p.join(saveRoot, 'repo.db');
    final task = Global.downloadManager.add(DownloadTask(
      url: '/api/meta/db/repo.db',
      category: DownloadCategory.database,
      savePath: dbPath,
      client: _client,
    ));
    await task.start();

    // 3. rename json after db downloaded
    await jsonFile.rename(jsonPath);
  }

  Future<List<TagInfo>> getTags() async {
    final response = await _client.get('/api/meta/tags');
    return (response.data as List<dynamic>)
        .map((e) => TagInfo.fromJson(e))
        .toList();
  }

  Future<Map<String, List<String>>> getTagsRelationship() async {
    final response = await _client.get('/api/meta/tag-graph');
    return (response.data as Map<String, dynamic>).map((key, value) => MapEntry(
        key, (value as List<dynamic>).map((e) => e.toString()).toList()));
  }

  Future<List<Album>> getAlbumsByTag(String tag) async {
    final response = await _client
        .get('/api/meta/albums/by-tag', queryParameters: {'tag': tag});
    return (response.data as List<dynamic>)
        .map((e) => Album.fromJson(e))
        .toList();
  }
}
