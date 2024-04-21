import 'dart:io';

import 'package:flutter/material.dart';

extension AnnixContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  bool get isDesktopOrLandscape =>
      isDesktop || MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isApple => Platform.isIOS || Platform.isMacOS;

  bool get isMobileOrPortrait => !isDesktopOrLandscape;
}
