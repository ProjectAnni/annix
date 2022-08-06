import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixTheme {
  static AnnixTheme _instance = AnnixTheme._();

  factory AnnixTheme() {
    return _instance;
  }

  AnnixTheme._({
    Color seed = const Color.fromARGB(0xff, 0xbe, 0x08, 0x73),
  })  : _seed = seed,
        _theme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: seed,
        ),
        _darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: seed,
        );

  Color _seed;

  ThemeData _theme;
  ThemeData get theme => _theme;

  ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;

  void setTheme(Color seed, [bool apply = true]) {
    if (_seed == seed) {
      return;
    }

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
}
