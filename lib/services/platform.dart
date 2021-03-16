import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AnniPlatform {
  // Web platform
  static bool get isWeb => kIsWeb;

  // Desktop platforms
  static bool get isSupportedDesktop => Platform.isWindows || Platform.isLinux;

  // Mobile platforms
  static bool get isSupportedMobile =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  // Only Fuchsia is not supported for now
  static bool get isSupported => !Platform.isFuchsia;
}
