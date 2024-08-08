import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/download/download_models.dart';
import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/utils/hash.dart';
import 'package:annix/utils/cookie_storage.dart';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'package:f_logs/f_logs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
  final Ref ref;

  AnnivClient(this.ref,
      {required final String url, required final CookieJar cookieJar})
      : _client = Dio(
          BaseOptions(
            baseUrl: url,
            responseType: ResponseType.json,
            contentType: Headers.jsonContentType,
          ),
        ),
        _cookieJar = cookieJar {
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(InterceptorsWrapper(
      onRequest: (final options, final handler) {
        options.queryParameters
            .removeWhere((final key, final value) => value == false);
        return handler.next(options);
      },
      onResponse: (final response, final handler) {
        if (response.statusCode != 200) {
          // response status of anniv MUST be 200
          return handler.reject(DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.unknown,
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
            handler.reject(DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.unknown,
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

  static PersistCookieJar _loadCookieJar(final Ref ref) {
    return PersistCookieJar(
      storage: CookieStorage(ref.read(preferencesProvider)),
      ignoreExpires: true,
      persistSession: true,
    );
  }

  static Future<AnnivClient> login(
    final Ref ref, {
    required final String url,
    required final String email,
    required final String password,
  }) async {
    final client = AnnivClient(ref, url: url, cookieJar: _loadCookieJar(ref));
    await client._login(email: email, password: password);
    await client._save();
    return client;
  }

  /// Load anniv url from shared preferences & load cookies
  /// If no url is found or not login, return null
  static AnnivClient? load(final Ref ref) {
    final preferences = ref.read(preferencesProvider);
    final annivUrl = preferences.getString('anniv_url');
    if (annivUrl == null) {
      return null;
    } else {
      return AnnivClient(ref, url: annivUrl, cookieJar: _loadCookieJar(ref));
    }
  }

  /// Save anniv url to shared preferences
  Future<void> _save() async {
    ref.read(preferencesProvider).set('anniv_url', _client.options.baseUrl);
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
    required final String email,
    required final String password,
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
    _client.post('/api/user/logout').catchError((final err) {});
    _cookieJar.deleteAll();
    ref.read(preferencesProvider).remove('anniv_url');
    return;
  }

  /// https://book.anni.rs/06.anniv/04.credential.html#%E8%8E%B7%E5%8F%96-token
  Future<List<AnnilToken>> getCredentials() async {
    final response = await _client.get('/api/credential');
    return (response.data as List<dynamic>)
        .map((final e) => AnnilToken.fromJson(e))
        .toList();
  }

  /// https://book.anni.rs/06.anniv/04.credential.html#%E4%BF%AE%E6%94%B9-token
  Future<void> updateCredential(
    final String id, {
    final String? name,
    final String? url,
    final String? token,
    final int? priority,
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
  Future<Map<String, Album>> getAlbumMetadata(final List<String> albums) async {
    final response =
        await _client.get('/api/meta/album', queryParameters: {'id[]': albums});
    final Map<String, dynamic> responseAlbums = response.data;
    responseAlbums.removeWhere((final _, final value) => value == null);
    return responseAlbums
        .map((final key, final value) =>
            MapEntry(key, value as Map<String, dynamic>))
        .map(
          (final albumId, final album) => MapEntry(
            albumId,
            Album.fromJson(album),
          ),
        );
  }

  // https://book.anni.rs/06.anniv/09.search.html
  Future<SearchResult> search(
    final String keyword, {
    final bool searchAlbums = false,
    final bool searchTracks = false,
    final bool searchPlaylists = false,
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
  Future<List<TrackInfoWithAlbum>> getFavoriteTracks() async {
    final response = await _client.get('/api/favorite/music');
    return (response.data as List<dynamic>)
        .map((final e) => TrackInfoWithAlbum.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E6%B7%BB%E5%8A%A0%E5%8D%95%E6%9B%B2
  Future<void> addFavoriteTrack(final TrackIdentifier track) async {
    await _client.put('/api/favorite/music', data: {
      'album_id': track.albumId,
      'disc_id': track.discId,
      'track_id': track.trackId,
    });
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E5%88%A0%E9%99%A4%E5%8D%95%E6%9B%B2
  Future<void> removeFavoriteTrack(final TrackIdentifier track) async {
    await _client.delete('/api/favorite/music', data: {
      'album_id': track.albumId,
      'disc_id': track.discId,
      'track_id': track.trackId,
    });
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E8%8E%B7%E5%8F%96%E6%94%B6%E8%97%8F%E4%B8%93%E8%BE%91%E5%88%97%E8%A1%A8
  Future<List<String>> getFavoriteAlbums() async {
    final response = await _client.get('/api/favorite/album');
    return (response.data as List<dynamic>).cast<String>();
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E6%B7%BB%E5%8A%A0%E6%94%B6%E8%97%8F%E4%B8%93%E8%BE%91
  Future<void> addFavoriteAlbum(final String albumId) async {
    await _client.put('/api/favorite/album', data: {
      'album_id': albumId,
    });
  }

  // https://book.anni.rs/06.anniv/10.favorite.html#%E5%88%A0%E9%99%A4%E6%94%B6%E8%97%8F%E4%B8%93%E8%BE%91
  Future<void> removeFavoriteAlbum(final String albumId) async {
    await _client.delete('/api/favorite/album', data: {
      'album_id': albumId,
    });
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E8%8E%B7%E5%8F%96%E6%8C%87%E5%AE%9A%E7%94%A8%E6%88%B7%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<List<PlaylistInfo>> getPlaylistByUserId([final String? userId]) async {
    final response = await _client.get('/api/playlists', queryParameters: {
      if (userId != null) 'user_id': userId,
    });
    return (response.data as List<dynamic>)
        .map((final e) => PlaylistInfo.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E8%8E%B7%E5%8F%96%E6%8C%87%E5%AE%9A%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> getPlaylistDetail(final String id) async {
    final response =
        await _client.get('/api/playlist', queryParameters: {'id': id});
    return Playlist.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E5%88%9B%E5%BB%BA%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> createPlaylist({
    required final String name,
    required final String description,
    final bool public = true,
    final DiscIdentifier? cover,
    final List<AnnivPlaylistItem> items = const [],
  }) async {
    final response = await _client.put('/api/playlist', data: {
      'name': name,
      'description': description,
      'is_public': public,
      'cover': cover?.toJson(),
      'items': items.map((final e) => e.toJson()).toList(),
    });
    return Playlist.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E4%BF%AE%E6%94%B9%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> updatePlaylistInfo({
    required final String playlistId,
    required final PatchedPlaylistInfo info,
  }) async {
    final response = await _client.patch('/api/playlist', data: {
      'id': playlistId,
      'command': 'info',
      'payload': info.toJson(),
    });
    return Playlist.fromJson(response.data);
  }

  // https://book.anni.rs/06.anniv/03.playlist.html#%E4%BF%AE%E6%94%B9%E6%92%AD%E6%94%BE%E5%88%97%E8%A1%A8
  Future<Playlist> appendPlaylistItem({
    required final String playlistId,
    required final List<AnnivPlaylistPlainItem> items,
  }) async {
    final response = await _client.patch('/api/playlist', data: {
      'id': playlistId,
      'command': 'append',
      'payload': items.map((final e) => e.toJson()).toList(),
    });
    return Playlist.fromJson(response.data);
  }

  Future<LyricResponse?> getLyric(final TrackIdentifier track) async {
    try {
      final response = await _client.get('/api/lyric', queryParameters: {
        'album_id': track.albumId,
        'disc_id': track.discId,
        'track_id': track.trackId,
      });
      return LyricResponse.fromJson(response.data);
    } on DioException catch (e) {
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

  Future<void> downloadRepoDatabase(final String saveRoot) async {
    // 1. download json
    final jsonPath = p.join(saveRoot, 'repo.json');
    await _client.download('/api/meta/db/repo.json', '$jsonPath.downloading');
    final jsonFile = File('$jsonPath.downloading');

    // 2. download db
    final dbPath = p.join(saveRoot, 'repo.db');
    final task = ref.read(downloadManagerProvider).add(DownloadTask(
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
        .map((final e) => TagInfo.fromJson(e))
        .toList();
  }

  Future<Map<String, List<String>>> getTagsRelationship() async {
    final response = await _client.get('/api/meta/tag-graph');
    return (response.data as Map<String, dynamic>).map(
        (final key, final value) => MapEntry(key,
            (value as List<dynamic>).map((final e) => e.toString()).toList()));
  }

  Future<List<Album>> getAlbumsByTag(final String tag) async {
    final response = await _client
        .get('/api/meta/albums/by-tag', queryParameters: {'tag': tag});
    return (response.data as List<dynamic>)
        .map((final e) => Album.fromJson(e))
        .toList();
  }

  // https://book.anni.rs/06.anniv/06.statistics.html#%E6%92%AD%E6%94%BE%E8%AE%B0%E5%BD%95
  Future<void> trackPlayback(final List<SongPlayRecord> records) async {
    if (records.isNotEmpty) {
      await _client.post(
        '/api/stat',
        data: records.map((final e) => e.toJson()).toList(),
      );
    }
  }

  // https://book.anni.rs/06.anniv/06.statistics.html#%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E7%94%A8%E6%88%B7%E6%92%AD%E6%94%BE%E8%AE%B0%E5%BD%95
  Future<List<SongPlayRecordResult>> getUserPlaybackStats() async {
    final response = await _client.get('/api/stat/self', queryParameters: {
      'from': 0,
    });
    return (response.data as List<dynamic>)
        .map((final e) => SongPlayRecordResult.fromJson(e))
        .toList();
  }
}
