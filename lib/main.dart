import 'package:annix/app.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/platform.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_ume/flutter_ume.dart';
// import 'package:flutter_ume_kit_ui/flutter_ume_kit_ui.dart';
// import 'package:flutter_ume_kit_perf/flutter_ume_kit_perf.dart';
// import 'package:flutter_ume_kit_show_code/flutter_ume_kit_show_code.dart';
// import 'package:flutter_ume_kit_device/flutter_ume_kit_device.dart';
// import 'package:flutter_ume_kit_console/flutter_ume_kit_console.dart';
import 'package:annix/third_party/just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AnniPlatform.isMobile || AnniPlatform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'rs.anni.annix.audio',
      androidNotificationChannelName: 'Annix Audio playback',
      androidNotificationIcon: 'drawable/ic_notification',
      androidOnNotificationClick: () => Get.toNamed('/playing'),
      androidNotificationOngoing: true,
      artDownscaleHeight: 500,
      artDownscaleWidth: 500,
      preloadArtwork: true,
    );
  }

  await Global.init();

  // if (kDebugMode) {
  //   PluginManager.instance
  //     ..register(WidgetInfoInspector())
  //     ..register(WidgetDetailInspector())
  //     ..register(ColorSucker())
  //     ..register(AlignRuler())
  //     ..register(ColorPicker())
  //     ..register(TouchIndicator())
  //     ..register(Performance())
  //     ..register(ShowCode())
  //     ..register(MemoryInfoPage())
  //     ..register(CpuInfoPage())
  //     ..register(DeviceInfoPanel())
  //     ..register(Console());
  //   runApp(UMEWidget(child: AnnixApp(), enable: true));
  // } else {
  runApp(AnnixApp());
  // }
}
