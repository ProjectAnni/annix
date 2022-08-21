import 'package:annix/app.dart';
import 'package:annix/services/settings_controller.dart';
import 'package:annix/global.dart';
import 'package:annix/services/annil/cover.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLog.getDefaultConfigurations().isDevelopmentDebuggingEnabled = true;

  await Global.init();
  Get.put(SettingsController());
  await CoverReverseProxy().setup();

  try {
    runApp(const AnnixApp());
  } catch (e) {
    FLog.error(text: "Uncaught exception", exception: e);
  }
}
