import 'package:annix/services/font.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AnnixTheme extends ChangeNotifier {
  AnnixTheme({Color seed = const Color.fromARGB(0xff, 0xbe, 0x08, 0x73)})
      : _seed = seed,
        _theme = FlexThemeData.light(
          useMaterial3: true,
          scheme: FlexScheme.indigo,
          fontFamily: FontService.getFontFamilyName(),
        ),
        _darkTheme = FlexThemeData.dark(
          useMaterial3: true,
          scheme: FlexScheme.indigo,
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
      fontFamily: FontService.getFontFamilyName(),
    );
    _darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: _seed,
      fontFamily: FontService.getFontFamilyName(),
    );
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setFontFamily() {
    setTheme(_seed, force: true);
  }
}
