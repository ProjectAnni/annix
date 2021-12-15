import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AnniPlatform {
  // Web platform
  static bool get isWeb => kIsWeb;

  // Desktop platforms
  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  // Mobile platforms
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // Only Fuchsia is not supported for now
  static bool get isSupported => !Platform.isFuchsia;

  static bool get isMacOS => Platform.isMacOS;

  static bool get isApple => Platform.isMacOS || Platform.isIOS;
}
