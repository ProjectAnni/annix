import 'dart:io';

import 'package:annix/services/download/download_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

typedef DownloadCallback<T> = void Function(T);

class DownloadCancelledError extends Error {}

class DownloadTask extends ChangeNotifier {
  static final Dio _client = Dio();

  final DownloadTaskData data;
  final DownloadCategory category;

  final String url;
  final Map<String, String> headers;
  final String savePath;
  final Dio? client;

  DownloadTaskStatus status = DownloadTaskStatus.paused;
  DownloadProgress progress = const DownloadProgress(current: 0);
  CancelToken _cancelToken = CancelToken();

  DownloadCallback<Response<dynamic>>? onSuccess;

  DownloadTask({
    this.data = const DownloadTaskData(),
    required this.category,
    required this.url,
    this.headers = const {},
    required this.savePath,
    this.client,
  });

  Response<dynamic>? _response;

  Future<Response<dynamic>> start() async {
    if (status == DownloadTaskStatus.downloading ||
        status == DownloadTaskStatus.completed) {
      return _response!;
    } else {
      _response = await _start();
      return _response!;
    }
  }

  Future<Response<dynamic>?> _start() async {
    if (status == DownloadTaskStatus.downloading ||
        status == DownloadTaskStatus.completed) {
      return null;
    }

    try {
      final client = this.client ?? _client;
      final response = await client.download(
        url,
        '$savePath.tmp',
        options: Options(
          headers: headers,
          followRedirects: false,
          extra: {'annil-dl-url': url},
        ),
        onReceiveProgress: (final count, final total) {
          status = DownloadTaskStatus.downloading;
          progress =
              DownloadProgress(current: count, total: total > 0 ? total : null);
          notifyListeners();
        },
        cancelToken: _cancelToken,
      );
      if (_cancelToken.isCancelled) {
        throw DownloadCancelledError;
      }

      status = DownloadTaskStatus.completed;
      notifyListeners();

      File('$savePath.tmp').renameSync(savePath);
      onSuccess?.call(response);
      return response;
    } catch (e) {
      status = DownloadTaskStatus.failed;
      notifyListeners();

      if (e is DioException) {
        if (e.type == DioExceptionType.cancel) {
          throw DownloadCancelledError();
        }
      }
      rethrow;
    }
  }

  void cancel() {
    _cancelToken.cancel();
  }

  Future<void> retry() {
    cancel();
    _cancelToken = CancelToken();
    _response = null;
    return start();
  }
}
