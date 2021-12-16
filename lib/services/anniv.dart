import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/hash.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class AnnivClient {
  final Dio _client;
  final CookieJar _cookieJar;
  late AnnilClient annil;
  List<String> albums = [];

  AnnivClient._({
    required String url,
    required CookieJar cookieJar,
  })  : _client = Dio(BaseOptions(baseUrl: url)),
        _cookieJar = cookieJar {
    _client.interceptors.add(CookieManager(_cookieJar));
    _client.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.responseType = ResponseType.json;
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
            // business logic error code
            handler.reject(DioError(
              requestOptions: response.requestOptions,
              response: response,
              type: DioErrorType.response,
              // TODO: error message from error code
              error: resp['message'] ?? 'Unknown error reason',
            ));
          } else {
            dynamic data = resp['data'];
            handler.resolve(Response(
              requestOptions: response.requestOptions,
              data: data,
            ));
          }
        }
      },
    ));
  }

  static Future<PersistCookieJar> _loadCookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    return PersistCookieJar(storage: FileStorage(dir.path));
  }

  static Future<AnnivClient> create({
    required String url,
    required String email,
    required String password,
  }) async {
    final client = AnnivClient._(url: url, cookieJar: await _loadCookieJar());
    await client.login(email: email, password: password);
    await client._save();
    final credentials = await client.getCredentials();
    client.annil = AnnilClient(
        baseUrl: credentials[0].url, authorization: credentials[0].token);
    client.albums = await client.annil.getAlbums();
    return client;
  }

  /// Load anniv url from shared preferences & load cookies
  /// If no url is found or not login, return null
  static Future<AnnivClient?> load() async {
    String? annivUrl = Global.preferences.getString('anniv_url');
    if (annivUrl == null) {
      return null;
    } else {
      final client =
          AnnivClient._(url: annivUrl, cookieJar: await _loadCookieJar());
      try {
        // TODO: save user info & site info
        // try validate login
        await client.getSiteInfo();
        await client.getUserInfo();
        final credentials = await client.getCredentials();
        client.annil = AnnilClient(
            baseUrl: credentials[0].url, authorization: credentials[0].token);
        client.albums = await client.annil.getAlbums();
        return client;
      } catch (e) {
        // failed to get user info
        return null;
      }
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
  Future<UserInfo> login({
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
    await _client.post("/api/user/logout");
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
            Album.fromMap({
              'album': album,
              'discs': (album['discs'] as List<dynamic>).map((e) {
                var disc = e as Map<String, dynamic>;
                e['tracks'] = (disc['tracks'] as List<dynamic>)
                    .map((e) => e as Map<String, dynamic>)
                    .toList();
                return disc;
              }).toList(),
            }),
          ),
        );
  }
}
