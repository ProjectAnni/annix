import 'package:annix/ui/page/anniv_login.dart';
import 'package:annix/ui/page/download_manager.dart';
import 'package:annix/ui/page/playlist/playlist_page_album.dart';
import 'package:annix/ui/page/playlist/playlist_page_favorite.dart';
import 'package:annix/ui/page/playlist/playlist_page_list.dart';
import 'package:annix/ui/page/server.dart';
import 'package:annix/ui/page/tag/tag_list.dart';
import 'package:annix/ui/page/settings/settings.dart';
import 'package:annix/ui/page/settings/settings_log.dart';
import 'package:annix/ui/page/tag/tag_detail.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/page/home/home.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/page/search.dart';
import 'package:annix/ui/route/page.dart';
import 'package:flutter/material.dart';

class AnnixRouterDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  final List<AnnixPage> _pages = [];
  final Map<String, AnnixPage> _reservedPages = {};

  @override
  final GlobalKey<NavigatorState> navigatorKey = Global.navigatorKey;

  AnnixRouterDelegate() {
    to(name: '/home');
  }

  @override
  Widget build(BuildContext context) {
    final reserved = _reservedPages.values
        .where((element) => !_pages.contains(element))
        .toList();

    return AnnixLayout.build(
      context,
      router: this,
      child: Navigator(
        key: navigatorKey,
        pages: reserved + _pages,
        onPopPage: _onPopPage,
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) async {}

  @override
  Future<bool> popRoute() async {
    final rootNavigator = Navigator.of(Global.context, rootNavigator: true);

    if (await rootNavigator.maybePop()) {
      return true;
    } else if (Global.mobileWeSlideController.isOpened) {
      Global.mobileWeSlideController.hide();
      return true;
    } else if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return true;
    } else {
      // can not pop, exit
      return false;
    }
  }

  String get currentRoute => _pages.last.name!;

  bool canPop() {
    return _pages.length > 1;
  }

  bool _onPopPage<T>(Route<T> route, T result) {
    if (!route.didPop(result)) return false;

    if (canPop()) {
      _pages.removeLast();
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void to({required String name, arguments}) {
    // FIXME: dedup
    // if (currentRoute == name) {
    //   return;
    // }

    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  void off({required String name, arguments}) {
    _pages.clear();
    to(name: name, arguments: arguments);
  }

  void replace({required String name, arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    to(name: name, arguments: arguments);
  }

  AnnixPage _createPage(RouteSettings routeSettings) {
    if (_reservedPages.containsKey(routeSettings.name)) {
      return _reservedPages[routeSettings.name]!;
    }

    Widget child;
    bool disableAppBarDismissal = false;

    switch (routeSettings.name) {
      case '/login':
        child = const AnnivLoginPage();
        break;
      case '/playing':
        // /playing route is only available on desktop
        child = const PlayingDesktopScreen();
        disableAppBarDismissal = true;
        break;
      case '/home':
        child = const HomePage();
        disableAppBarDismissal = true;
        break;
      case '/album':
        if (routeSettings.arguments is String) {
          // albumId
          child =
              LazyAlbumDetailScreen(albumId: routeSettings.arguments as String);
        } else {
          child = AlbumDetailScreen(album: routeSettings.arguments as Album);
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
        disableAppBarDismissal = true;
        break;
      case '/favorite':
        child = const FavoriteScreen();
        break;
      case '/playlist':
        child = LazyPlaylistDetailScreen(id: routeSettings.arguments as int);
        break;
      case '/search':
        child = const SearchPage();
        break;
      case '/settings':
        child = const SettingsScreen();
        break;
      case '/settings/log':
        child = const SettingsLogView();
        break;
      case '/downloading':
        child = const DownloadManagerPage();
        break;
      default:
        throw UnimplementedError(
            "You've entered an unknown area! This should not happen.");
    }

    final reserved = _reservedPages[routeSettings.name!];
    if (reserved != null) {
      return reserved;
    }

    final page = AnnixPage(
      child: child,
      name: routeSettings.name,
      arguments: routeSettings.arguments,
      key: Key(routeSettings.name!) as LocalKey,
      disableAppBarDismissal: disableAppBarDismissal,
    );

    if (routeSettings.name == '/playing') {
      _reservedPages[routeSettings.name!] = page;
    }
    return page;
  }

  static AnnixRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is AnnixRouterDelegate, 'Delegate type must match');
    return delegate as AnnixRouterDelegate;
  }
}
