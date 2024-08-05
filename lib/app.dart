import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    );
  }
}
