import 'dart:async';
import 'dart:io' show File;

import 'package:annix/services/global.dart';
import 'package:extended_image/extended_image.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:http_plus/http_plus.dart';
import 'package:path/path.dart' as p;

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}

class CoverImage extends StatelessWidget {
  static final client = HttpPlusClient(enableHttp2: false);
  static final downloadingMap = Map();

  final String? albumId;
  final int? discId;
  final String? remoteUrl;

  final BoxFit? fit;
  final FilterQuality filterQuality;

  final String? tag;

  const CoverImage({
    Key? key,
    this.remoteUrl,
    this.albumId,
    this.discId,
    this.fit,
    this.filterQuality = FilterQuality.low,
    this.tag,
  }) : super(key: key);

  Future<File?> getCoverImage() async {
    if (downloadingMap.containsKey(remoteUrl!)) {
      await downloadingMap[remoteUrl!];
    }

    final coverImagePath = getCoverCachePath(albumId!, discId);
    final file = File(coverImagePath);
    if (!await file.exists()) {
      if (remoteUrl == null) {
        // offline mode
        return null;
      }

      // fetch remote cover
      final getRequest = client.get(Uri.parse(remoteUrl!));
      downloadingMap[remoteUrl!] = getRequest;
      final response = await getRequest;
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

  Widget dummy() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (albumId == null) {
      return dummy();
    }

    return FutureBuilder<File?>(
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
          FLog.error(text: "Failed to load cover", exception: snapshot.error);
        }

        return dummy();
      },
    );
  }
}
