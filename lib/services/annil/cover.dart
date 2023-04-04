import 'package:annix/providers.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:dio/dio.dart';
import 'dart:io' show File;

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
  _CoverReverseProxy(this.ref);

  final client = Dio();
  final Ref ref;
  final downloadingMap = {};

  Future<File?> getCoverImage(final CoverItem cover) async {
    final annil = ref.read(annilProvider);

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

        // response stream to UInt8List
        final data = response.data;
        if (data != null) {
          await file.writeAsBytes(data);
          downloadingMap.remove(cover.key);
        }
      }
    }
    return file;
  }
}

final coverProxyProvider = Provider((final ref) => _CoverReverseProxy(ref));
