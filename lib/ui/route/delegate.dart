import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart' as db;
import 'package:annix/services/theme.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/page/annil/annil.dart';
import 'package:annix/ui/page/anniv_login.dart';
import 'package:annix/ui/page/download_manager.dart';
import 'package:annix/ui/page/favorite.dart';
import 'package:annix/ui/page/playback_history.dart';
import 'package:annix/ui/page/playlist.dart';
import 'package:annix/ui/page/server.dart';
import 'package:annix/ui/page/tag/tag_list.dart';
import 'package:annix/ui/page/settings/settings.dart';
import 'package:annix/ui/page/settings/settings_log.dart';
import 'package:annix/ui/page/tag/tag_detail.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/home/home.dart';
import 'package:annix/ui/page/search.dart';
import 'package:annix/ui/route/page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';

class AnnixRouterDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  final _panelController = PanelController();
  get panelController => _panelController;
  get isPanelOpen =>
      _panelController.isAttached &&
      (_panelController.isPanelOpen ||
          _panelController.isPanelAnimating ||
          _panelController.panelPosition > 0.9);
  get isPanelClosed => !isPanelOpen;

  void openPanel() {
    if (!_panelController.isPanelOpen) {
      _panelController.open();
      notifyListeners();
    }
  }

  void closePanel() {
    if (isPanelOpen) {
      _panelController.close();
      notifyListeners();
    }
  }

  final Ref ref;
  final List<AnnixPage> _pages = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  AnnixRouterDelegate(this.ref) {
    to(name: '/home');
  }

  @override
  Widget build(final BuildContext context) {
    final child = Navigator(
      key: navigatorKey,
      // copy once, or it will not be rebuilt
      pages: [..._pages],
      observers: [ThemePopObserver(ref.read(themeProvider))],
      onPopPage: _onPopPage,
    );
    return AnnixLayout(
      router: this,
      child: child,
    );
  }

  @override
  Future<void> setNewRoutePath(final List<RouteSettings> configuration) async {}

  @override
  Future<bool> popRoute() async {
    final rootNavigator =
        Navigator.of(navigatorKey.currentContext!, rootNavigator: true);

    if (await rootNavigator.maybePop()) {
      return true;
    } else if (isPanelOpen) {
      closePanel();
      return true;
    } else if (_canPop()) {
      _pages.removeLast();
      notifyListeners();
      return true;
    } else {
      // can not pop, exit
      return false;
    }
  }

  bool mayPop() {
    if (isPanelOpen) {
      return true;
    } else {
      return _canPop();
    }
  }

  String get currentRoute => _pages.last.name!;

  bool _canPop() {
    return _pages.length > 1;
  }

  bool _onPopPage<T>(final Route<T> route, final T result) {
    if (!route.didPop(result)) return false;

    if (_canPop()) {
      _pages.removeLast();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void to({
    required final String name,
    final arguments,
    final AnnixRoutePageBuilder? pageBuilder,
    final Duration? transitionDuration,
  }) {
    // FIXME: dedup
    // if (currentRoute == name) {
    //   return;
    // }
    closePanel();

    _pages.add(_createPage(
      RouteSettings(name: name, arguments: arguments),
      pageBuilder: pageBuilder,
      transitionDuration: transitionDuration,
    ));
    notifyListeners();
  }

  void off({
    required final String name,
    final arguments,
    final AnnixRoutePageBuilder? pageBuilder,
    final Duration? transitionDuration,
  }) {
    closePanel();

    _pages.clear();
    to(
      name: name,
      arguments: arguments,
      pageBuilder: pageBuilder,
      transitionDuration: transitionDuration,
    );
  }

  void replace({
    required final String name,
    final arguments,
    final AnnixRoutePageBuilder? pageBuilder,
    final Duration? transitionDuration,
  }) {
    closePanel();

    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    to(
      name: name,
      arguments: arguments,
      pageBuilder: pageBuilder,
      transitionDuration: transitionDuration,
    );
  }

  AnnixPage _createPage(
    final RouteSettings routeSettings, {
    final AnnixRoutePageBuilder? pageBuilder,
    final Duration? transitionDuration,
  }) {
    Widget child;
    bool? disableAppBarDismissal;

    switch (routeSettings.name) {
      case '/login':
        child = const AnnivLoginPage();
        break;
      case '/home':
        child = const HomePage();
        disableAppBarDismissal = true;
        break;
      case '/album':
        if (routeSettings.arguments is String) {
          // albumId
          final albumId = routeSettings.arguments as String;
          child = LoadingAlbumPage(albumId: albumId);
          ref.read(themeProvider).pushTemporaryTheme(albumId);
        } else {
          final album = routeSettings.arguments as Album;
          child = AlbumPage(album: album);
          ref.read(themeProvider).pushTemporaryTheme(album.albumId);
        }
        break;
      case '/tag':
        child = TagDetailScreen(
          name: routeSettings.arguments as String,
        );
        break;
      case '/tags':
        child = const TagListView();
        disableAppBarDismissal = true;
        break;
      case '/server':
        child = const ServerView();
        break;
      case '/annil':
        child = AnnilDetailPage(
          annil: routeSettings.arguments as db.LocalAnnilServer,
        );
        break;
      case '/favorite':
        child = const FavoritePage();
        break;
      case '/playlist':
        child = LoadingPlaylistPage(
            playlistInfo: routeSettings.arguments as PlaylistInfo);
        break;
      case '/search':
        child = const SearchPage();
        break;
      case '/settings':
        child = const SettingsScreen();
        disableAppBarDismissal = true;
        break;
      case '/settings/log':
        child = const SettingsLogView();
        break;
      case '/downloading':
        child = const DownloadManagerPage();
        break;
      case '/history':
        child = const PlaybackHistoryPage();
        break;
      default:
        throw UnimplementedError(
            "You've entered an unknown area! This should not happen.");
    }

    final page = AnnixPage(
      child: child,
      name: routeSettings.name,
      arguments: routeSettings.arguments,
      key: Key(routeSettings.name!) as LocalKey,
      disableAppBarDismissal: disableAppBarDismissal,
      pageBuilder: pageBuilder,
      transitionDuration: transitionDuration,
    );

    return page;
  }

  @Deprecated('Use `ref.read` instead')
  static AnnixRouterDelegate of(final BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is AnnixRouterDelegate, 'Delegate type must match');
    return delegate as AnnixRouterDelegate;
  }
}
