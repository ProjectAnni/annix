import 'package:annix/utils/theme.preset.anni.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixTheme {
  static AnnixTheme _instance = AnnixTheme._();

  factory AnnixTheme() {
    return _instance;
  }

  AnnixTheme._() {
    // TODO: load seed from config
    setPresetTheme();
    // setTheme(Color.fromARGB(255, 184, 253, 127), false);
  }

  void setPresetTheme() {
    _theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: anniLightColorScheme,
    );
    _darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: anniDarkColorScheme,
    );
  }

  void setTheme(Color seed, [bool apply = true]) {
    _seed = seed;
    _theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: _seed,
    );
    _darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: _seed,
    );

    if (apply) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (Get.isDarkMode) {
          Get.changeTheme(_darkTheme);
        } else {
          Get.changeTheme(_theme);
        }
      });
    }
  }

  late Color _seed;

  late ThemeData _theme;
  ThemeData get theme => _theme;

  late ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;
}
