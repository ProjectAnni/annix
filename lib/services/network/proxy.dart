import 'dart:io';

import 'package:annix/services/annil/cover.dart';
import 'package:extended_image/extended_image.dart' hide Request;
import 'package:flutter/material.dart' hide Router;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// This proxy is only used for serving cover images for system notification.
class AnnixProxy {
  final Ref ref;

  AnnixProxy(this.ref);

  late HttpServer server;

  Future<AnnixProxy> start() async {
    final app = Router();
    final coverProxy = ref.read(coverProxyProvider);

    app.get('/cover/<albumId>',
        (final Request request, final String albumId) async {
      final image = await coverProxy.getCoverImage(albumId: albumId);
      if (image != null) {
        return Response.ok(image.openRead(), headers: {
          'Content-Type': 'image/jpg',
        });
      } else {
        return Response.notFound('Not found');
      }
    });
    server = await shelf_io.serve(app, InternetAddress.loopbackIPv4, 0);
    return this;
  }

  ImageProvider<Object> coverProvider(final String albumId, final int? discId) {
    final coverProxy = ref.read(coverProxyProvider);
    final coverFile =
        coverProxy.getCoverImageFile(albumId: albumId, discId: discId);
    if (coverFile != null) {
      return ExtendedFileImageProvider(coverFile);
    }

    return ExtendedNetworkImageProvider(coverUri(albumId, discId).toString());
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
