import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class AnnixProxy {
  HttpServer? server;

  start() async {
    var app = Router();

    app.get('/cover/<albumId>', (Request request, String albumId) {
      return Response.ok('hello-world');
    });
    server = await shelf_io.serve(app, InternetAddress.loopbackIPv4, 0);
  }
}
