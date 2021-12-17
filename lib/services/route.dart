import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AnnixDesktopRouter extends ChangeNotifier {
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
    if (routeName == _currentRoute) {
      return Future.value();
    }
    _lastRoute = _currentRoute;
    _currentRoute = routeName;
    notifyListeners();
    return navigator.pushReplacementNamed(_currentRoute);
  }

  Future<void> pushReplacementLast() {
    String tmp = _currentRoute;
    _currentRoute = _lastRoute!;
    _lastRoute = tmp;
    notifyListeners();
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

  /// Route: settings
  static const String settings = '/settings';
  bool get isPlaylistSettings => _currentRoute == settings;
  bool get isPlaylistLastSettings => _lastRoute == settings;
}
