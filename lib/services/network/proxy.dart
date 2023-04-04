import 'dart:async';
import 'dart:io';

import 'package:annix/global.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/network/cover.dart';
import 'package:dio/dio.dart' hide Response;
import 'package:provider/provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class AnnixProxy {
  late HttpServer server;

  Future<void> start() async {
    final app = Router();

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

    final client = Dio();
    app.get('/audio/<albumId>/<discId>/<trackId>/<quality>', (
      Request request,
      String albumId,
      String discId,
      String trackId,
      String quality,
    ) async {
      final track = TrackIdentifier(
        albumId: albumId,
        discId: int.parse(discId),
        trackId: int.parse(trackId),
      );
      final file = File(getAudioCachePath(track));
      if (file.existsSync()) {
        return Response.ok(file.openRead(), headers: {
          'Content-Length': '${file.lengthSync()}',
        });
      }

      final annil = Global.context.read<AnnilService>();
      final url = await annil.getAudioUrl(
        track: track,
        quality: PreferQuality.fromString(quality),
      );
      if (url == null) {
        return Response.notFound('Not found');
      }

      final response = await client.get<ResponseBody>(
        url,
        options: Options(responseType: ResponseType.stream),
      );

      final saveFile = File('${file.path}.proxy-tmp');
      await saveFile.parent.create(recursive: true);
      final writeSink = saveFile.openWrite(mode: FileMode.write);

      final body = response.data!.stream.asBroadcastStream();
      writeSink.addStream(body).then((_) async {
        await writeSink.close();
        saveFile.renameSync(file.path);
      });

      return Response(
        200,
        headers: response.headers.map,
        body: body,
      );
    });
    server = await shelf_io.serve(app, InternetAddress.loopbackIPv4, 0);

    print(server.port);
  }

  String coverUrl(String albumId, [int? discId]) {
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

  Uri audioUri(TrackIdentifier track, PreferQuality quality) {
    return Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
      path:
          '/audio/${track.albumId}/${track.discId}/${track.trackId}/${quality.toString()}',
    );
  }
}
