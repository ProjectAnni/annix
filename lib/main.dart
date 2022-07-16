import 'package:annix/app.dart';
import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/network_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FLog.getDefaultConfigurations()..isDevelopmentDebuggingEnabled = true;

  await Future.wait([Global.init(), CoverReverseProxy().setup()]);

  try {
    Get.put(NetworkController());
    Get.put(SettingsController());
    Get.put(await AnnilController.init());
    Get.put(await AnnivController.init());
    Get.put(PlayerController());

    runApp(AnnixApp());
  } catch (e) {
    FLog.error(text: "Uncaught exception", exception: e);
  }
}
