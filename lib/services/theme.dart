import 'package:annix/services/font.dart';
import 'package:flutter/material.dart';

class AnnixTheme extends ChangeNotifier {
  String? fontFamily;

  AnnixTheme({Color seed = const Color.fromARGB(0xff, 0xbe, 0x08, 0x73)})
      : _seed = seed,
        fontFamily = FontService.getFontFamilyName(),
        _theme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: seed,
          fontFamily: FontService.getFontFamilyName(),
        ),
        _darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: seed,
          fontFamily: FontService.getFontFamilyName(),
        ),
        _themeMode = ThemeMode.system;

  Color _seed;

  ThemeData _theme;
  ThemeData get theme => _theme;

  ThemeData _darkTheme;
  ThemeData get darkTheme => _darkTheme;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setTheme(Color seed, {bool force = false}) {
    if (_seed == seed && !force) {
      return;
    }

    _seed = seed;
    _theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: _seed,
      fontFamily: fontFamily,
    );
    _darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: _seed,
      fontFamily: fontFamily,
    );
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setFontFamily(String? fontFamily) {
    this.fontFamily = fontFamily;
    setTheme(_seed, force: true);
  }
}
