import 'package:annix/global.dart';
import 'package:flutter/material.dart';

extension AnnixContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDesktop => Global.isDesktop;

  bool get isDesktopOrLandscape =>
      Global.isDesktop ||
      MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isMobileOrPortrait => !isDesktopOrLandscape;
}
