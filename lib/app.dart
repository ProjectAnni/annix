import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/playing/playing.dart';
import 'package:annix/pages/desktop/main_desktop.dart';
import 'package:annix/pages/root/root.dart';
import 'package:annix/pages/search.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Annix",
      debugShowCheckedModeBanner: false,
      // theme
      theme: AnnixTheme().theme,
      darkTheme: AnnixTheme().darkTheme,
      // i18n
      locale: Get.deviceLocale,
      translations: I18n(),
      fallbackLocale: const Locale('en', 'US'),
      // routes
      initialRoute: Global.isDesktop ? '/desktop' : '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => RootScreen(),
          binding: RootScreenBinding(),
        ),
        GetPage(
          name: '/desktop',
          page: () => MainDesktopScreen(),
          binding: DesktopMainScreenBinding(),
        ),
        GetPage(
          name: '/playing',
          page: () => PlayingScreen(),
        ),
        GetPage(
          name: '/search',
          page: () => SearchScreen(),
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsScreen(),
        ),
      ],
      builder: (context, child) => ResponsiveWrapper.builder(
        child,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.resize(600, name: MOBILE),
          ResponsiveBreakpoint.autoScale(800, name: TABLET),
          ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
          ResponsiveBreakpoint.autoScale(2400, name: '4K'),
        ],
      ),
    );
  }
}
