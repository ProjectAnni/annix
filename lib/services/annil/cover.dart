import 'package:annix/providers.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io' show File, HttpClient;

import 'package:hooks_riverpod/hooks_riverpod.dart';

class CoverItem {
  final String albumId;
  final int? discId;

  CoverItem({
    required this.albumId,
    this.discId,
  });

  String get key => discId == null ? albumId : '$albumId/$discId';
}

class _CoverReverseProxy {
  _CoverReverseProxy(this.ref) {
    client.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (final cert, final host, final port) =>
                  ref.read(settingsProvider).skipCertificateVerification.value;
          return client;
        },
        validateCertificate: (final cert, final host, final port) => true);
  }

  final client = Dio();
  final Ref ref;
  final downloadingMap = {};

  File? getCoverImageFile({required String albumId, int? discId}) {
    final cover = CoverItem(albumId: albumId, discId: discId);
    if (downloadingMap.containsKey(cover.key)) {
      return null;
    }

    final coverImagePath = getCoverCachePath(cover.albumId, cover.discId);
    final file = File(coverImagePath);

    if (!file.existsSync()) {
      return null;
    }
    return file;
  }

  Future<File?> getCoverImage({required String albumId, int? discId}) async {
    final annil = ref.read(annilProvider);
    final cover = CoverItem(albumId: albumId, discId: discId);

    if (downloadingMap.containsKey(cover.key)) {
      await downloadingMap[cover.key];
    }

    final coverImagePath = getCoverCachePath(cover.albumId, cover.discId);
    final file = File(coverImagePath);

    if (!await file.exists()) {
      final uri =
          await annil.getCoverUrl(albumId: cover.albumId, discId: cover.discId);
      if (uri == null) {
        return null;
      }

      // fetch remote cover
      // TODO: retry
      final getRequest = client.getUri<List<int>>(
        uri,
        options: Options(responseType: ResponseType.bytes),
      );
      downloadingMap[cover.key] = getRequest;
      final response = await getRequest;
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        try {
          // response stream to UInt8List
          final data = response.data;
          if (data != null) {
            await file.writeAsBytes(data);
            downloadingMap.remove(cover.key);
          }
        } catch (e) {
          await file.delete();
        }
      }
    }
    return file;
  }
}

final coverProxyProvider = Provider((final ref) => _CoverReverseProxy(ref));
