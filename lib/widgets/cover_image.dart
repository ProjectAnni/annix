import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:annix/services/global.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

String getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return p.join(Global.storageRoot, "cover", fileName);
}

class CoverImage extends StatelessWidget {
  final String albumId;
  final int? discId;
  final String? remoteUrl;

  final BoxFit? fit;
  final FilterQuality filterQuality;

  const CoverImage({
    Key? key,
    this.remoteUrl,
    required this.albumId,
    this.discId,
    this.fit,
    this.filterQuality = FilterQuality.low,
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
      final request = await HttpClient().getUrl(Uri.parse(remoteUrl!));
      final response = await request.close();
      if (response.statusCode == 200) {
        // create folder
        await file.parent.create(recursive: true);

        // response stream to Uint8List
        final data = (await response.toList()).expand((e) => e).toList();
        final raw = Uint8List.fromList(data);
        await file.writeAsBytes(raw);
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
          return ExtendedImage.file(
            snapshot.data!,
            fit: fit,
            filterQuality: filterQuality,
            compressionRatio: 0.5,
          );
        } else if (snapshot.hasError) {
          // TODO: show error
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
