import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AnnixApp extends ConsumerWidget {
  const AnnixApp({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final delegate = ref.read(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Annix',
      debugShowCheckedModeBanner: false,

      // theme
      theme: theme.theme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,

      // i18n
      locale: (locale.value ?? LocaleSettings.currentLocale).flutterLocale,
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
                valueListenable: ref.read(settingsProvider).autoScaleUI,
                builder: (final context, final value, final child) {
                  if (value) {
                    return ResponsiveBreakpoints.builder(
                      child: child!,
                      breakpoints: const [
                        Breakpoint(start: 0, end: 600, name: MOBILE),
                        Breakpoint(start: 600, end: 800, name: TABLET),
                        Breakpoint(start: 800, end: 1200, name: DESKTOP),
                        Breakpoint(
                            start: 1200, end: double.infinity, name: '4K'),
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
