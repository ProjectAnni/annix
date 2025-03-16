import 'package:annix/app.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/path.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:annix/native/frb_generated.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:annix/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // try to initialize firebase, but don't crash if it fails as linux is not supported
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
  } catch (_) {}
  FlutterError.onError = (final details) {
    if (firebaseInitialized) {
      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }

    Logger.error(
      'Flutter error',
      className: details.library,
      exception: details.exception,
      stacktrace: details.stack,
    );

    FlutterError.presentError(details);
  };

  await RustLib.init();
  await PathService.init();
  // logger requires path service, and is required by all other services
  Logger.init();

  final container = ProviderContainer();
  await Future.wait([
    container.read(proxyProvider).start(),
    container.read(audioServiceProvider.future),
  ]);

  await LocaleSettings.useDeviceLocale();

  PlatformDispatcher.instance.onError = (final error, final stack) {
    Logger.error('Root isolate error', exception: error, stacktrace: stack);
    return true;
  };

  try {
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const AnnixApp(),
      ),
    );
  } catch (e) {
    Logger.error('Uncaught exception', exception: e);
  }
}
