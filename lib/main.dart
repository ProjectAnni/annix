import 'package:annix/app.dart';
import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/services/global.dart';
import 'package:annix/services/cover.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLog.getDefaultConfigurations().isDevelopmentDebuggingEnabled = true;

  await Global.init();
  Get.put(SettingsController());
  await Get.putAsync(() => AnnilController.init());
  await Get.putAsync(() => AnnivController.init());

  await CoverReverseProxy().setup();

  try {
    runApp(const AnnixApp());
  } catch (e) {
    FLog.error(text: "Uncaught exception", exception: e);
  }
}
