import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeButton extends StatelessWidget {
  const ThemeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        Get.changeThemeMode(
          context.isDarkMode ? ThemeMode.light : ThemeMode.dark,
        );
      },
    );
  }
}
