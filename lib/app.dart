import 'package:annix/services/audio_handler.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:provider/provider.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GetX-related
    Get.locale = Get.deviceLocale;
    Get.fallbackLocale = const Locale('en', 'US');
    Get.addTranslations(I18n().keys);

    // global router delegate
    final delegate = AnnixRouterDelegate(
      builder: (context, child) => AnnixLayout.build(child: child),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnixTheme(), lazy: false),
        ChangeNotifierProvider(create: (_) => PlayerService(), lazy: false),
        ChangeNotifierProvider(create: (_) => PlayingProgress(), lazy: false),
        Provider(create: (c) => AnnixAudioHandler.init(c), lazy: false),
      ],
      builder: (context, child) {
        final theme = Provider.of<AnnixTheme>(context);
        return MaterialApp.router(
          title: "Annix",
          debugShowCheckedModeBanner: false,

          // theme
          theme: theme.theme,
          darkTheme: theme.darkTheme,
          // i18n
          locale: Get.locale,

          // routes
          routerDelegate: delegate,

          // TODO: add an options in the future
          builder: (context, child) {
            return ResponsiveWrapper.builder(
              child,
              defaultScale: true,
              breakpoints: [
                ResponsiveBreakpoint.resize(600, name: MOBILE),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(2400, name: '4K'),
              ],
            );
          },
        );
      },
    );
  }
}
