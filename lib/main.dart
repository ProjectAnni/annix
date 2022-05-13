import 'dart:io';

import 'package:annix/app.dart';
import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/network_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/services/global.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:annix/third_party/just_audio_background/just_audio_background.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'rs.anni.annix.audio',
      androidNotificationChannelName: 'Annix Audio playback',
      androidNotificationIcon: 'drawable/ic_notification',
      androidOnNotificationClick: () => Get.toNamed('/playing'),
      androidNotificationOngoing: true,
      artDownscaleHeight: 300,
      artDownscaleWidth: 300,
      preloadArtwork: true,
    );
  }

  FLog.getDefaultConfigurations()..isDevelopmentDebuggingEnabled = true;

  await Global.init();

  try {
    Get.put(NetworkController());
    Get.put(await AnnilController.init());
    Get.put(await AnnivController.init());
    Get.put(PlayingController());

    runApp(AnnixApp());
  } catch (e) {
    FLog.error(text: "Uncaught exception", exception: e);
  }
}
