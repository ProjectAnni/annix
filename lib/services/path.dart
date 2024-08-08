import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PathService {
  static late final String storageRoot;
  static late final String dataRoot;

  static Future<void> init() async {
    final isPortableMode = File(p.normalize(
            p.join(Platform.resolvedExecutable, '..', 'portable.enable')))
        .existsSync();

    if (Platform.isMacOS) {
      storageRoot = p.join((await getLibraryDirectory()).path, 'data');
      dataRoot = storageRoot;
    } else if (Platform.isLinux || Platform.isWindows) {
      if (isPortableMode) {
        dataRoot =
            p.normalize(p.join(Platform.resolvedExecutable, '..', 'data'));
      } else {
        dataRoot = (await getApplicationSupportDirectory()).path;
      }
      storageRoot = p.join(dataRoot, 'cache');
    } else {
      // save data in getApplicationDocumentsDirectory() on mobile
      dataRoot = (await getApplicationDocumentsDirectory()).path;
      if (Platform.isIOS) {
        storageRoot = (await getLibraryDirectory()).path;
      } else {
        storageRoot = (await getExternalStorageDirectory())!.path;
      }
    }

    debugPrint('storageRoot: $storageRoot');
    debugPrint('dataRoot: $dataRoot');
  }
}

String localDbPath() => p.join(PathService.dataRoot, 'local.db');
String audioCachePath() => p.join(PathService.storageRoot, 'audio');
String coverCachePath() => p.join(PathService.storageRoot, 'cover');
String logPath() => p.join(PathService.dataRoot, 'log.db');
