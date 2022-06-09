import 'dart:async';
import 'dart:io';

import 'package:annix/metadata/metadata_source.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Global {
  static late SharedPreferences preferences;

  static Completer<MetadataSource> metadataSource = Completer();

  static bool isDesktop =
      Platform.isLinux || Platform.isWindows || Platform.isWindows;

  static late String storageRoot;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();

    if (Platform.isIOS) {
      storageRoot = (await getApplicationDocumentsDirectory()).path;
    } else if (isDesktop) {
      storageRoot =
          p.normalize(p.join(Platform.resolvedExecutable, '..', 'data'));

      // sqflite on desktop
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      storageRoot = (await getExternalStorageDirectory())!.path;
    }
  }
}
