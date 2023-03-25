import 'package:annix/app.dart';
import 'package:annix/global.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FLog.getDefaultConfigurations().isDevelopmentDebuggingEnabled = true;

  // Initialize with default values.
  await SimpleAudio.init(
    useMediaController: true,
    shouldNormalizeVolume: false,
    dbusName: 'rs.anni.annix',
    actions: [
      MediaControlAction.rewind,
      MediaControlAction.skipPrev,
      MediaControlAction.playPause,
      MediaControlAction.skipNext,
      MediaControlAction.fastForward
    ],
    androidNotificationIconPath: 'mipmap/ic_launcher',
    androidCompactActions: [1, 2, 3],
    applePreferSkipButtons: true,
  );

  await Global.init();
  LocaleSettings.useDeviceLocale();

  FlutterError.onError = (details) {
    FLog.error(
      text: 'Flutter error',
      className: details.library,
      exception: details.exception,
      stacktrace: details.stack,
    );

    FlutterError.presentError(details);
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
