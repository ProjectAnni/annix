import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:synchronized/synchronized.dart';

Future<String> getCoverCachePath(String albumId, int? discId) {
  final fileName = "${discId == null ? "$albumId" : "${albumId}_$discId"}.jpg";
  return getExternalStorageDirectory()
      .then((root) => p.join(root!.path, "cover", fileName));
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

  Future<Uint8List> getCoverImage() async {
    final coverImagePath = await getCoverCachePath(albumId, discId);
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
        LRUImageCache.instance.cacheData(raw, "$albumId/$discId");
        await file.writeAsBytes(raw);
        return raw;
      } else {
        throw Exception("Failed to fetch cover image");
      }
    } else {
      // local file exists, load to cache
      final raw = await file.readAsBytes();
      LRUImageCache.instance.cacheData(raw, "$albumId/$discId");
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = "$albumId/$discId";
    if (LRUImageCache.instance.contains(key)) {
      return Image.memory(
        LRUImageCache.instance.get(key)!,
        fit: fit,
        filterQuality: filterQuality,
      );
    } else {
      return FutureBuilder<Uint8List>(
        future: getCoverImage(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              gaplessPlayback: true,
              fit: fit,
              filterQuality: filterQuality,
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
}

// Modified from [https://github.com/DragonCherry/lru_image_cache]
//
// lru_image_cache is available under the MIT license. See the LICENSE file for more info.
//
// MIT License
//
// Copyright (c) 2020 DragonCherry
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
class LRUImageCache {
  static final instance = LRUImageCache();

  final _lock = Lock();
  final _sizeCache = Map<String, Size>();
  final _identifiers = <String>[];
  final _map = Map<String, Uint8List>();

  int maximumBytes = 64 * 1024 * 1024; // default 64MB
  int currentBytes = 0;

  void cacheData(final Uint8List imageBytes, final String key) {
    _lock.synchronized(() {
      if (currentBytes + imageBytes.length <= maximumBytes) {
        currentBytes += imageBytes.length;
      } else {
        do {
          if (_identifiers.isNotEmpty) {
            final lastIdentifier = _identifiers.removeLast();
            final imageBytesToRemove = _map.remove(lastIdentifier)!;
            currentBytes -= imageBytesToRemove.length;
          } else {
            break;
          }
        } while (currentBytes + imageBytes.length >= maximumBytes);
      }
      _map[key] = imageBytes;
      _identifiers.insert(0, key);
    });
  }

  Size? size(final String identifier) {
    return _sizeCache[identifier];
  }

  bool contains(final String url) {
    return _identifiers.contains(url);
  }

  Uint8List? get(final String identifier) {
    return _map[identifier];
  }

  void clear() {
    _sizeCache.clear();
    _identifiers.clear();
    _map.clear();
  }
}
