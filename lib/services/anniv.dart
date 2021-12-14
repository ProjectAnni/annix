import 'package:annix/models/anniv.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/hash.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class AnnivClient {
  final Dio client;
  final CookieJar cookieJar;

  AnnivClient._({
    required String url,
    required this.cookieJar,
  }) : client = Dio(BaseOptions(baseUrl: url)) {
    client.interceptors.add(CookieManager(cookieJar));
    client.interceptors.add(InterceptorsWrapper(
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

  static Future<AnnivClient> create({
    required String url,
    required String email,
    required String password,
  }) async {
    // FIXME: path to persistent cookie file
    final cookieJar = PersistCookieJar();
    final client = AnnivClient._(
      url: url,
      cookieJar: cookieJar,
    );
    await client.login(email: email, password: password);
    return client;
  }

  /// Load anniv url from shared preferences & load cookies
  static Future<AnnivClient?> load() async {
    String? annivUrl = Global.preferences.getString('anniv_url');
    if (annivUrl == null) {
      return null;
    } else {
      // try to login
      final client = AnnivClient._(
        url: annivUrl,
        cookieJar: PersistCookieJar(),
      );
      try {
        // TODO: save user info & site info
        await client.getUserInfo();
        await client.getSiteInfo();
        return client;
      } catch (e) {
        // failed to get user info
        return null;
      }
    }
  }

  /// Save anniv url to shared preferences
  Future<void> save() async {
    await Global.preferences.setString('anniv_url', client.options.baseUrl);
  }

  /// Get site info from Anniv server
  ///
  /// This method should be called before any other requests were sent to the server.
  /// https://book.anni.rs/06.anniv/01.info.html
  Future<SiteInfo> getSiteInfo() async {
    final response = await client.get("/api/info");
    return SiteInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E4%BF%A1%E6%81%AF
  Future<UserInfo> getUserInfo() async {
    final response = await client.get("/api/user/info");
    return UserInfo.fromJson(response.data);
  }

  /// https://book.anni.rs/06.anniv/02.user.html#%E7%94%A8%E6%88%B7%E7%99%BB%E5%BD%95
  Future<UserInfo> login({
    required String email,
    required String password,
  }) async {
    final response = await client.post(
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
    await client.post("/api/user/logout");
  }

  ////////////////////////////////////////////////////////////
  // Annil Token Management
  ////////////////////////////////////////////////////////////
}
