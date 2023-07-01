import 'package:dio/dio.dart';

// Writes headers of a redirect to subsequent responses.
class RedirectInterceptor extends Interceptor {
  Dio client;
  Map<String, Headers> headers = {};

  RedirectInterceptor(this.client);

  @override
  void onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) {
    final url = response.requestOptions.extra['annil-dl-url'];
    if (url != null && headers.containsKey(url)) {
      final h = headers[url]!;
      for (final key in [
        'X-Origin-Type',
        'X-Origin-Size',
        'X-Duration-Seconds',
        'X-Audio-Quality'
      ]) {
        response.headers.set(key, h[key]);
      }
      headers.remove(url);
    }

    handler.next(response);
  }

  @override
  Future<dynamic> onError(
    final DioError err,
    final ErrorInterceptorHandler handler,
  ) async {
    if (err.type == DioErrorType.badResponse && err.response!.isRedirect) {
      final url = err.requestOptions.extra['annil-dl-url'];
      if (url != null) {
        headers.putIfAbsent(url, () => err.response!.headers);
        final opt = err.requestOptions;
        opt.followRedirects = true;
        try {
          await client.fetch(opt).then((final value) => handler.resolve(value));
        } on DioError catch (e) {
          super.onError(e, handler);
        }
      }
    }
  }
}
