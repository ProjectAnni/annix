import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AnnixDesktopRouter {
  static GlobalKey _view = GlobalKey();

  static GlobalKey get navigatorKey => _view;

  static NavigatorState get navigator => _view.currentState as NavigatorState;

  String? _lastRoute;
  String _currentRoute;
  String get currentRoute => _currentRoute;

  AnnixDesktopRouter({String initialRoute = albums})
      : _currentRoute = initialRoute;

  static AnnixDesktopRouter of(BuildContext context, {bool listen = true}) =>
      Provider.of(context, listen: listen);

  Future<void> pushReplacementNamed(String routeName) {
    _lastRoute = _currentRoute;
    _currentRoute = routeName;
    return navigator.pushReplacementNamed(_currentRoute);
  }

  Future<void> pushReplacementLast() {
    String tmp = _currentRoute;
    _currentRoute = _lastRoute!;
    _lastRoute = tmp;
    return navigator.pushReplacementNamed(_currentRoute);
  }

  /// Route: albums
  static const String albums = '/albums';
  bool get isAlbumsRoute => _currentRoute == albums;
  bool get isAlbumsLastRoute => _lastRoute == albums;

  /// Route: playlist
  static const String playlist = '/playlist';
  bool get isPlaylistRoute => _currentRoute == playlist;
  bool get isPlaylistLastRoute => _lastRoute == playlist;
}
