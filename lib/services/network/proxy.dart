import 'dart:io';

import 'package:annix/services/annil/cover.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class AnnixProxy {
  late HttpServer server;

  Future<void> start() async {
    var app = Router();

    app.get('/cover/<albumId>', (Request request, String albumId) async {
      final image =
          await CoverReverseProxy().getCoverImage(CoverItem(albumId: albumId));
      if (image != null) {
        return Response.ok(image.openRead(), headers: {
          'Content-Type': 'image/jpg',
        });
      } else {
        return Response.notFound('Not found');
      }
    });
    server = await shelf_io.serve(app, InternetAddress.loopbackIPv4, 0);
  }

  String coverUrl(String albumId, int? discId) {
    return coverUri(albumId, discId).toString();
  }

  Uri coverUri(String albumId, int? discId) {
    return Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
      path: '/cover/$albumId',
    );
  }
}
