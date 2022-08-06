import 'package:http_plus/http_plus.dart';
import 'dart:io' show File, HttpServer, InternetAddress, ContentType;
import 'package:path/path.dart' as p;
import 'package:annix/services/global.dart';

class CoverItem {
  final String albumId;
  final int? discId;
  final Uri? uri;

  CoverItem({
    required this.albumId,
    this.discId,
    this.uri,
  });

  String get key => '$albumId/$discId';
}

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}

class CoverReverseProxy {
  static final client = HttpPlusClient(enableHttp2: false);
  static CoverReverseProxy? _instance;

  late HttpServer proxy;
  final Map<String, CoverItem> _urlMap = Map();
  final downloadingMap = Map();

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
    if (_instance == null) {
      _instance = CoverReverseProxy._();
    }
    return _instance!;
  }

  Uri url(CoverItem remote) {
    final key = remote.key;
    _urlMap[key] ??= remote;
    return Uri(scheme: 'http', host: "127.0.0.1", port: proxy.port, path: key);
  }

  Future<File?> getCoverImage(CoverItem cover) async {
    if (downloadingMap.containsKey(cover.uri.toString())) {
      await downloadingMap[cover.uri.toString()];
    }

    final coverImagePath = getCoverCachePath(cover.albumId, cover.discId);
    final file = File(coverImagePath);
    if (!await file.exists()) {
      if (cover.uri == null) {
        return null;
      }

      // fetch remote cover
      final getRequest = client.get(cover.uri!);
      downloadingMap[cover.uri.toString()] = getRequest;
      final response = await getRequest;
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        // response stream to Uint8List
        final data = response.bodyBytes;
        await file.writeAsBytes(data);
        downloadingMap.remove(cover.uri.toString());
      }
    }
    return file;
  }
}
