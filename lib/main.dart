import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter_ume/flutter_ume.dart';
import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart';
import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart';
import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart';
import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart';
import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  if (AnniPlatform.isMobile || AnniPlatform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'rs.anni.annix.audio',
      androidNotificationChannelName: 'Annix Audio playback',
      androidNotificationOngoing: true,
    );
  }

  // if (AnniPlatform.isDesktop) {
  //   doWhenWindowReady(() {
  //     const initialSize = Size(1280, 720);
  //     appWindow.minSize = initialSize;
  //     appWindow.size = initialSize;
  //     appWindow.alignment = Alignment.center;
  //     appWindow.show();
  //   });
  // }

  await Global.init();

  // if (AnniPlatform.isDesktop) {
  //   // Initialize FFI
  //   sqfliteFfiInit();
  //   // Change the default factory
  //   databaseFactory = databaseFactoryFfi;
  // }

  if (kDebugMode) {
    PluginManager.instance
      ..register(WidgetInfoInspector())
      ..register(WidgetDetailInspector())
      ..register(ColorSucker())
      ..register(AlignRuler())
      ..register(ColorPicker())
      ..register(TouchIndicator())
      ..register(Performance())
      ..register(ShowCode())
      ..register(MemoryInfoPage())
      ..register(CpuInfoPage())
      ..register(DeviceInfoPanel())
      ..register(Console());
    runApp(UMEWidget(child: AnnixApp(), enable: true));
  } else {
    runApp(AnnixApp());
  }
}
