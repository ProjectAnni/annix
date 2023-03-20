import 'package:annix/global.dart';
import 'package:annix/services/font.dart';
import 'package:flutter/material.dart';

class AnnixTheme extends ChangeNotifier {
  AnnixTheme()
      : _primaryColor = Colors.indigo,
        _themeMode = ThemeMode.system;

  // main theme generated by now-playing cover
  Color _primaryColor;

  // temporary theme generated per-page
  Color? _temporaryPrimaryColor;

  ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: FontService.getFontFamilyName(),
        colorSchemeSeed: _temporaryPrimaryColor ?? _primaryColor,
      );
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: FontService.getFontFamilyName(),
        colorSchemeSeed: _temporaryPrimaryColor ?? _primaryColor,
      );

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  void setTemporaryScheme(ColorScheme scheme) {
    _temporaryPrimaryColor = scheme.primary;
    notifyListeners();
  }

  void revokeTemporaryScheme() {
    if (_temporaryPrimaryColor != null) {
      final oldTemporaryPrimaryColor = _temporaryPrimaryColor;
      _temporaryPrimaryColor = null;

      if (oldTemporaryPrimaryColor != _primaryColor) {
        notifyListeners();
      }
    }
  }

  void setScheme(ColorScheme scheme) {
    _primaryColor = scheme.primary;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode != _themeMode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void updateFontFamily() {
    notifyListeners();
  }
}

class ThemePopObserver extends NavigatorObserver {
  @override
  didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Global.theme.revokeTemporaryScheme();
    });
  }
}
