import 'package:flutter/material.dart';

class AnnixTheme extends ChangeNotifier {
  AnnixTheme({Color seed = const Color.fromARGB(0xff, 0xbe, 0x08, 0x73)})
      : _seed = seed,
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

  void setTheme(Color seed) {
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
    notifyListeners();
  }
}
