import 'package:annix/global.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/client.dart';
import 'package:http_plus/http_plus.dart';
import 'dart:io' show File;

import 'package:provider/provider.dart';

class CoverItem {
  final String albumId;
  final int? discId;

  CoverItem({
    required this.albumId,
    this.discId,
  });

  String get key => discId == null ? albumId : '$albumId/$discId';
}

class CoverReverseProxy {
  static final client = HttpPlusClient(enableHttp2: false);
  static CoverReverseProxy? _instance;

  final downloadingMap = {};

  CoverReverseProxy._();

  factory CoverReverseProxy() {
    _instance ??= CoverReverseProxy._();
    return _instance!;
  }

  Future<File?> getCoverImage(CoverItem cover) async {
    final CombinedOnlineAnnilClient annil = Global.context.read();

    if (downloadingMap.containsKey(cover.key)) {
      await downloadingMap[cover.key];
    }

    final coverImagePath = getCoverCachePath(cover.albumId, cover.discId);
    final file = File(coverImagePath);
    if (!await file.exists()) {
      final uri =
          annil.getCoverUrl(albumId: cover.albumId, discId: cover.discId);
      if (uri == null) {
        return null;
      }

      // fetch remote cover
      // TODO: retry
      final getRequest = client.get(uri);
      downloadingMap[cover.key] = getRequest;
      final response = await getRequest;
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        // response stream to UInt8List
        final data = response.bodyBytes;
        await file.writeAsBytes(data);
        downloadingMap.remove(cover.key);
      }
    }
    return file;
  }
}
