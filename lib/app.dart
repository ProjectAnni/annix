import 'package:annix/global.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

class AnnixApp extends ConsumerWidget {
  const AnnixApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final delegate = ref.read(routerProvider);

    // load local / remote album list
    // FIXME: do not reload annil every time theme updates
    ref.read(annilProvider).reload();
    return MaterialApp.router(
      title: 'Annix',
      debugShowCheckedModeBanner: false,

      // theme
      theme: theme.theme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,

      // i18n
      locale: TranslationProvider.of(context).flutterLocale,
      // use provider
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,

      // routes
      routerDelegate: delegate,

      // scale
      builder: (final context, final child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (final context) => ValueListenableBuilder<bool>(
                valueListenable: Global.settings.autoScaleUI,
                builder: (final context, final value, final child) {
                  if (value) {
                    return ResponsiveWrapper.builder(
                      child,
                      defaultScale: true,
                      breakpoints: const [
                        ResponsiveBreakpoint.resize(600, name: MOBILE),
                        ResponsiveBreakpoint.autoScale(800, name: TABLET),
                        ResponsiveBreakpoint.autoScale(1200, name: DESKTOP),
                        ResponsiveBreakpoint.autoScale(2400, name: '4K'),
                      ],
                    );
                  } else {
                    return child!;
                  }
                },
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}
