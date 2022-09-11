import 'package:annix/app.dart';
import 'package:annix/global.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLog.getDefaultConfigurations().isDevelopmentDebuggingEnabled = true;

  await Global.init();
  LocaleSettings.useDeviceLocale();

  try {
    runApp(TranslationProvider(child: const AnnixApp()));
  } catch (e) {
    FLog.error(text: "Uncaught exception", exception: e);
  }
}
