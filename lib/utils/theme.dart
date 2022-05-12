import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixTheme {
  static AnnixTheme _instance = AnnixTheme._();

  factory AnnixTheme() {
    return _instance;
  }

  AnnixTheme._() {
    // TODO: load seed from config
    setTheme(Color.fromARGB(255, 184, 253, 127), false);
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
      Get.changeTheme(_theme);
      Get.changeTheme(_darkTheme);
    }
  }

  late Color _seed;

  late ThemeData _theme;
  ThemeData get theme => _theme;

  late ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;
}
