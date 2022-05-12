import 'dart:async';
import 'dart:io' show File;

import 'package:annix/services/global.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:http_plus/http_plus.dart';
import 'package:path/path.dart' as p;
// import 'dart:io';
// import 'package:cronet/cronet.dart';

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}

class CoverImage extends StatelessWidget {
  static final client = HttpPlusClient(enableHttp2: false);

  final String albumId;
  final int? discId;
  final String? remoteUrl;

  final BoxFit? fit;
  final FilterQuality filterQuality;

  final String? tag;

  const CoverImage({
    Key? key,
    this.remoteUrl,
    required this.albumId,
    this.discId,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
  }) : super(key: key);

  Future<File> getCoverImage() async {
    final coverImagePath = getCoverCachePath(albumId, discId);
    final file = File(coverImagePath);
    if (!await file.exists()) {
      if (remoteUrl == null) {
        // offline mode
        throw Exception("No remote url");
      }

      // fetch remote cover
      final response = await client.get(Uri.parse(remoteUrl!));
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        // response stream to Uint8List
        final data = response.bodyBytes;
        await file.writeAsBytes(data);
      } else {
        throw Exception("Failed to fetch cover image");
      }
    }
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: getCoverImage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final image = ExtendedImage.file(
            snapshot.data!,
            fit: fit,
            filterQuality: filterQuality,
            cacheHeight: 800,
            gaplessPlayback: true,
          );
          if (tag != null) {
            return Hero(tag: tag!, child: image);
          } else {
            return image;
          }
        } else if (snapshot.hasError) {
          // TODO: log error
          // TODO: show default cover
          return Container(
            child: Center(
              child: Text(
                snapshot.error.toString(),
              ),
            ),
          );
        } else {
          // loading
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          );
        }
      },
    );
  }
}
