import 'package:annix/services/audio_handler.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/services/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:provider/provider.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnixTheme()),
        ChangeNotifierProvider(create: (_) => PlayerService()),
        ChangeNotifierProvider(create: (_) => PlayingProgress()),
        Provider(create: (_) => AnnixAudioHandler.init())
      ],
      builder: (context, child) {
        final theme = Provider.of<AnnixTheme>(context);
        return GetMaterialApp(
          title: "Annix",
          debugShowCheckedModeBanner: false,
          // theme
          theme: theme.theme,
          darkTheme: theme.darkTheme,
          // i18n
          locale: Get.deviceLocale,
          translations: I18n(),
          fallbackLocale: const Locale('en', 'US'),
          // routes
          home: child,
          // builder: (context, child) => ResponsiveWrapper.builder(
          //   child,
          //   defaultScale: true,
          //   breakpoints: [
          //     ResponsiveBreakpoint.resize(600, name: MOBILE),
          //     ResponsiveBreakpoint.autoScale(800, name: TABLET),
          //     ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
          //     ResponsiveBreakpoint.autoScale(2400, name: '4K'),
          //   ],
          // ),
        );
      },
      child: AnnixLayout.build(),
    );
  }
}
