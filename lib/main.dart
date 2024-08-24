import 'package:annix/app.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:annix/services/logger.dart';
import 'package:annix/services/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:annix/native/frb_generated.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  await RustLib.init();

  WidgetsFlutterBinding.ensureInitialized();

  await PathService.init();
  // logger requires path service, and is required by all other services
  Logger.init();

  final container = ProviderContainer();
  await Future.wait([
    container.read(proxyProvider).start(),
    container.read(audioServiceProvider.future),
  ]);

  LocaleSettings.useDeviceLocale();

  FlutterError.onError = (final details) {
    Logger.error(
      'Flutter error',
      className: details.library,
      exception: details.exception,
      stacktrace: details.stack,
    );

    FlutterError.presentError(details);
  };
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
