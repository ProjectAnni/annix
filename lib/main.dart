import 'package:annix/app.dart';
import 'package:annix/global.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLog.getDefaultConfigurations().isDevelopmentDebuggingEnabled = true;

  await Global.init();
  LocaleSettings.useDeviceLocale();

  FlutterError.onError = (details) {
    FLog.error(
      text: 'Flutter error',
      exception: details,
      stacktrace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FLog.error(text: 'Root isolate error', exception: error, stacktrace: stack);
    return true;
  };

  try {
    runApp(TranslationProvider(child: const AnnixApp()));
  } catch (e) {
    FLog.error(text: 'Uncaught exception', exception: e);
  }
}
