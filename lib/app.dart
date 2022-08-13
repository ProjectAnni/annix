import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/settings_controller.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/audio_handler.dart';
import 'package:annix/services/network.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnixTheme(), lazy: false),
        ChangeNotifierProvider(create: (_) => NetworkService(), lazy: false),
        ChangeNotifierProvider(create: (_) => PlayerService(), lazy: false),
        ChangeNotifierProvider(create: (_) => PlayingProgress(), lazy: false),
        ChangeNotifierProvider(
          create: (context) {
            final network = Provider.of<NetworkService>(context, listen: false);
            final annil = CombinedOnlineAnnilClient.loadFromLocal();
            network.addListener(() => annil.reloadClients());
            return annil;
          },
          lazy: false,
        ),
        ChangeNotifierProvider(
            create: (_) => AnnixRouterDelegate(), lazy: false),
        // Anniv controller
        Provider(create: (c) => AnnivService(c), lazy: false),
        Provider(create: (c) => AnnixAudioHandler.init(c), lazy: false),
      ],
      builder: (context, child) {
        final theme = Provider.of<AnnixTheme>(context);
        final delegate =
            Provider.of<AnnixRouterDelegate>(context, listen: false);

        // load local / remote album list
        Provider.of<CombinedOnlineAnnilClient>(context, listen: false)
            .reloadClients();
        return MaterialApp.router(
          title: "Annix",
          debugShowCheckedModeBanner: false,

          // theme
          theme: theme.theme,
          darkTheme: theme.darkTheme,
          themeMode: theme.themeMode,
          // i18n
          locale: Get.locale,

          // routes
          routerDelegate: delegate,

          // scale
          builder: (context, child) {
            final SettingsController settings = Get.find();

            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Obx(
                    () => settings.autoScaleUI.value
                        ? ResponsiveWrapper.builder(
                            child,
                            defaultScale: true,
                            breakpoints: const [
                              ResponsiveBreakpoint.resize(600, name: MOBILE),
                              ResponsiveBreakpoint.autoScale(800, name: TABLET),
                              ResponsiveBreakpoint.autoScale(1200,
                                  name: DESKTOP),
                              ResponsiveBreakpoint.autoScale(2400, name: '4K'),
                            ],
                          )
                        : child!,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
