import 'package:annix/global.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/annil/client.dart';
import 'package:http_plus/http_plus.dart';
import 'dart:io' show File, HttpServer, InternetAddress, ContentType;

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

  late HttpServer proxy;
  final Map<String, CoverItem> _urlMap = {};
  final downloadingMap = {};

  Future<void> setup() {
    return HttpServer.bind(InternetAddress.loopbackIPv4, 0).then((server) {
      proxy = server;
      proxy.listen((request) async {
        if (request.method == 'GET') {
          var path = request.uri.path;
          if (path.startsWith('/')) {
            path = path.substring(1);
          }
          final coverItem = _urlMap[path];
          if (coverItem != null) {
            try {
              final cover = await getCoverImage(coverItem);
              if (cover != null) {
                request.response.statusCode = 200;
                request.response.headers.contentType =
                    ContentType.parse('image/jpg');
                await request.response.addStream(cover.openRead());
                return;
              }
            } finally {
              await request.response.close();
            }
          } else {
            request.response.statusCode = 404;
          }

          request.response.close();
          return;
        }
      });
    });
  }

  CoverReverseProxy._();

  factory CoverReverseProxy() {
    _instance ??= CoverReverseProxy._();
    return _instance!;
  }

  Uri url(CoverItem remote) {
    final key = remote.key;
    _urlMap[key] ??= remote;
    return Uri(scheme: 'http', host: "127.0.0.1", port: proxy.port, path: key);
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
