import 'dart:async';
import 'dart:io';

import 'package:annix/metadata/metadata_source.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Global {
  static late SharedPreferences preferences;

  static Completer<MetadataSource> metadataSource = Completer();

  static bool isDesktop =
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  static bool isApple = Platform.isMacOS || Platform.isIOS;

  static late String storageRoot;
  static late String dataRoot;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();

    if (isDesktop) {
      doWhenWindowReady(() {
        const initialSize = Size(1280, 800);
        appWindow.minSize = initialSize;
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.show();
      });

      if (Platform.isMacOS) {
        storageRoot = p.join((await getLibraryDirectory()).path, 'data');
        dataRoot = storageRoot;
      } else {
        storageRoot =
            p.normalize(p.join(Platform.resolvedExecutable, '..', 'cache'));
        dataRoot =
            p.normalize(p.join(Platform.resolvedExecutable, '..', 'data'));
      }

      // sqflite on desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      // save data in getApplicationDocumentsDirectory() on mobile
      dataRoot = (await getApplicationDocumentsDirectory()).path;
      if (Platform.isIOS) {
        storageRoot = (await getApplicationDocumentsDirectory()).path;
      } else {
        storageRoot = (await getExternalStorageDirectory())!.path;
      }
    }
  }
}
