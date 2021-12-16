import 'package:flutter/widgets.dart';

class AnnixDesktopRouter {
  static GlobalKey _view = GlobalKey();

  static GlobalKey get navigatorKey => _view;

  static NavigatorState get navigator => _view.currentState as NavigatorState;

  static String? _lastRoute;
  static late String _currentRoute;

  static void setInitialRoute(String routeName) {
    // ignore: unnecessary_null_comparison
    if (_currentRoute != null) {
      _currentRoute = routeName;
    }
  }

  static Future<void> pushReplacementNamed(String routeName) {
    _lastRoute = _currentRoute;
    _currentRoute = routeName;
    return navigator.pushReplacementNamed(_currentRoute);
  }

  static Future<void> pushReplacementLast() {
    String tmp = _currentRoute;
    _currentRoute = _lastRoute!;
    _lastRoute = tmp;
    return navigator.pushReplacementNamed(_currentRoute);
  }

  /// Route: albums
  static const String albums = '/albums';
  static bool get isAlbumsRoute => _currentRoute == albums;
  static bool get isAlbumsLastRoute => _lastRoute == albums;

  /// Route: playlist
  static const String playlist = '/playlist';
  static bool get isPlaylistRoute => _currentRoute == playlist;
  static bool get isPlaylistLastRoute => _lastRoute == playlist;
}
