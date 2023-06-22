import 'package:dio/dio.dart';

// Writes headers of a redirect to subsquent responses.
class RedirectInterceptor extends Interceptor {
  Headers? headers;

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
    if (headers == null &&
        response.statusCode! >= 300 &&
        response.statusCode! < 400) {
      headers = response.headers;
    } else if (headers != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      response.headers = headers!;
    }

    handler.next(response);
  }
}
