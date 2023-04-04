import 'package:annix/providers.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeButton extends ConsumerWidget {
  const ThemeButton({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    return IconButton(
      icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        ref.read(themeProvider).setThemeMode(
            context.isDarkMode ? ThemeMode.light : ThemeMode.dark);
      },
    );
  }
}
