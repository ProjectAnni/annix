import 'dart:io';

import 'package:annix/services/annil/cover.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class AnnixProxy {
  Ref<Object?> ref;
  AnnixProxy(this.ref);

  late HttpServer server;

  Future<void> start() async {
    final app = Router();
    final coverProxy = ref.read(coverProxyProvider);

    app.get('/cover/<albumId>',
        (final Request request, final String albumId) async {
      final image = await coverProxy.getCoverImage(CoverItem(albumId: albumId));
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

  String coverUrl(final String albumId, final int? discId) {
    return coverUri(albumId, discId).toString();
  }

  Uri coverUri(final String albumId, final int? discId) {
    return Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
      path: '/cover/$albumId',
    );
  }
}
