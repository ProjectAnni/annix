import 'package:annix/models/anniv.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class AnnivClient {
  final Dio client;
  final String email;
  final String password;

  AnnivClient({
    required String url,
    required this.email,
    required this.password,
  }) : client = Dio(BaseOptions(baseUrl: url)) {
    final cookieJar = PersistCookieJar();
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

  Future<SiteInfo> getSiteInfo() async {
    final response = await client.get("/api/info");
    return SiteInfo.fromJson(response.data);
  }

  Future<bool> isLogin() async {
    // client.post(path)
    return false;
  }
}
