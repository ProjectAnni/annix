import 'package:annix/services/theme.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        context.read<AnnixTheme>().setThemeMode(
            context.isDarkMode ? ThemeMode.light : ThemeMode.dark);
      },
    );
  }
}
