import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AnniPlatform.isMobile || AnniPlatform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'rs.anni.annix.audio',
      androidNotificationChannelName: 'Annix Audio playback',
      androidNotificationOngoing: true,
    );
  }

  if (AnniPlatform.isDesktop) {
    doWhenWindowReady(() {
      const initialSize = Size(1280, 720);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  await Global.init();

  if (AnniPlatform.isDesktop) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
  runApp(AnnixApp());
}
