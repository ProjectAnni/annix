import 'dart:io' show Platform;

class AnniPlatform {
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
