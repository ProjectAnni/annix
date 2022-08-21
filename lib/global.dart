import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:we_slide/we_slide.dart';

class Global {
  static late SharedPreferences preferences;

  static bool isDesktop =
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  static bool isApple = Platform.isMacOS || Platform.isIOS;

  static late String storageRoot;
  static late String dataRoot;

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  static BuildContext get context => navigatorKey.currentContext!;

  static final mobileWeSlideController = WeSlideController();

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

      final isPortableMode = File(p.normalize(
              p.join(Platform.resolvedExecutable, '..', 'portable.enable')))
          .existsSync();

      if (Platform.isMacOS) {
        storageRoot = p.join((await getLibraryDirectory()).path, 'data');
        dataRoot = storageRoot;
      } else {
        if (isPortableMode) {
          dataRoot =
              p.normalize(p.join(Platform.resolvedExecutable, '..', 'data'));
        } else {
          dataRoot = (await getApplicationSupportDirectory()).path;
        }
        storageRoot = p.join(dataRoot, 'cache');
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