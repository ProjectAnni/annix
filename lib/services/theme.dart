import 'package:animations/animations.dart';
import 'package:annix/native/api/simple.dart';
import 'package:annix/services/annil/cover.dart';
import 'package:annix/services/font.dart';
import 'package:annix/services/local/cache.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnixTheme extends ChangeNotifier {
  final Ref ref;
  final _cache = {};

  AnnixTheme(this.ref)
      : _primaryColor = Colors.indigo,
        _primaryScheme = ColorScheme.fromSeed(seedColor: Colors.indigo),
        _primaryDarkScheme = ColorScheme.fromSeed(
            seedColor: Colors.indigo, brightness: Brightness.dark),
        _themeMode = ThemeMode.system;

  static final _store = AnnixStore().category('color');

  // main theme generated by now-playing cover
  Color _primaryColor;
  ColorScheme _primaryScheme;
  ColorScheme _primaryDarkScheme;

  // temporary theme generated per-page
  Color? _temporaryColor;
  ColorScheme? _temporaryScheme;
  ColorScheme? _temporaryDarkScheme;

  PageTransitionsTheme get transitions => const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.windows: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeThroughPageTransitionsBuilder(),
          TargetPlatform.linux: FadeThroughPageTransitionsBuilder(),
        },
      );
  ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: FontService.getFontFamilyName(),
        colorScheme: _temporaryScheme ?? _primaryScheme,
        pageTransitionsTheme: transitions,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: _temporaryScheme?.surface ?? _primaryScheme.surface,
        ),
      );
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: FontService.getFontFamilyName(),
        colorScheme: _temporaryDarkScheme ?? _primaryDarkScheme,
        pageTransitionsTheme: transitions,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor:
              _temporaryDarkScheme?.surface ?? _primaryDarkScheme.surface,
        ),
      );

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  final List<String> _themeStack = [];
  String? get activeTemporaryTheme {
    if (_themeStack.isEmpty) {
      return null;
    }
    return _themeStack.last;
  }

  void pushTemporaryTheme(final String albumId) async {
    if (!_cache.containsKey(albumId)) {
      _cache[albumId] = _getSchemeFromCover(albumId);
    }

    _themeStack.add(albumId);
    final [scheme, darkScheme] = await _cache[albumId];
    if (activeTemporaryTheme == albumId && _temporaryScheme != scheme ||
        _temporaryDarkScheme != darkScheme) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        _setTemporaryScheme(scheme, darkScheme);
      });
    }
  }

  void popTemporaryTheme() {
    if (_temporaryColor != null) {
      final oldTemporaryPrimaryColor = _temporaryColor;
      _temporaryColor = null;
      _temporaryScheme = null;
      _temporaryDarkScheme = null;
      _themeStack.clear();

      if (oldTemporaryPrimaryColor != _primaryColor) {
        notifyListeners();
      }
    }
  }

  void setPrimaryTheme(String albumId) async {
    final [scheme, darkScheme] = await _getSchemeFromCover(albumId);
    _setScheme(scheme, darkScheme);
  }

  Future<List<ColorScheme>> _getSchemeFromCover(String albumId) async {
    final proxy = ref.read(coverProxyProvider);
    final image = await proxy.getCoverImage(albumId: albumId);
    final seed = await _getThemeColor(albumId, image!.path);
    final scheme = ColorScheme.fromSeed(seedColor: Color(seed));
    final darkScheme = ColorScheme.fromSeed(
        seedColor: Color(seed), brightness: Brightness.dark);

    return [scheme, darkScheme];
  }

  Future<int> _getThemeColor(String albumId, String path) async {
    final cached = await _store.get(path);
    if (cached != null) {
      return int.parse(cached);
    }

    final seed = await getThemeColor(path: path);
    await _store.set(path, seed.toString());
    return seed;
  }

  void _setTemporaryScheme(
      final ColorScheme scheme, final ColorScheme darkScheme) {
    _temporaryColor = scheme.primary;
    _temporaryScheme = scheme;
    _temporaryDarkScheme = darkScheme;
    notifyListeners();
  }

  void _setScheme(final ColorScheme scheme, final ColorScheme darkScheme) {
    _primaryColor = scheme.primary;
    _primaryScheme = scheme;
    _primaryDarkScheme = darkScheme;
    notifyListeners();
  }

  void setThemeMode(final ThemeMode mode) {
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
  final AnnixTheme theme;

  ThemePopObserver(this.theme);

  @override
  void didPush(Route route, Route? previousRoute) {
    // TODO: implement didPush
    super.didPush(route, previousRoute);
  }

  @override
  didPop(final Route<dynamic> route, final Route<dynamic>? previousRoute) {
    // if this route had pushed a theme, them pop it
    if (['/album', '/playlist'].contains(route.settings.name)) {
      WidgetsBinding.instance.addPostFrameCallback((final _) {
        theme.popTemporaryTheme();
      });
    }
  }
}
