import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/pages/playlist/playlist_album.dart';
import 'package:annix/pages/playlist/playlist_favorite.dart';
import 'package:annix/pages/playlist/playlist_list.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/pages/root/tags.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/pages/settings/settings_log.dart';
import 'package:annix/pages/tag.dart';
import 'package:annix/services/global.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/page/home/home.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/search.dart';
import 'package:annix/ui/route/page.dart';
import 'package:flutter/material.dart';

class AnnixRouterDelegate extends RouterDelegate<List<RouteSettings>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<RouteSettings>> {
  final List<AnnixPage> _pages = [];

  @override
  final GlobalKey<NavigatorState> navigatorKey = Global.navigatorKey;

  AnnixRouterDelegate() {
    to(name: "/home");
  }

  @override
  Widget build(BuildContext context) {
    return AnnixLayout.build(
      router: this,
      child: Navigator(
        key: navigatorKey,
        pages: List.of(_pages),
        onPopPage: _onPopPage,
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(List<RouteSettings> configuration) async {}

  @override
  Future<bool> popRoute() async {
    if (Global.mobileWeSlideController.isOpened) {
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

  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;

    if (canPop()) {
      _pages.removeLast();
      return true;
    } else {
      return false;
    }
  }

  void to({required String name, dynamic arguments}) {
    // FIXME: dedup
    // if (currentRoute == name) {
    //   return;
    // }

    _pages.add(_createPage(RouteSettings(name: name, arguments: arguments)));
    notifyListeners();
  }

  void off({required String name, dynamic arguments}) {
    _pages.clear();
    to(name: name, arguments: arguments);
  }

  void replace({required String name, dynamic arguments}) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    to(name: name, arguments: arguments);
  }

  AnnixPage _createPage(RouteSettings routeSettings) {
    Widget child;

    switch (routeSettings.name) {
      case "/playing":
        // /playing route is only available on desktop
        child = const PlayingDesktopScreen();
        break;
      case "/home":
        child = HomePage();
        break;
      case "/album":
        child = AlbumDetailScreen(
          album: routeSettings.arguments as Album,
        );
        break;
      case "/tag":
        child = TagScreen(
          name: routeSettings.arguments as String,
        );
        break;
      case "/tags":
        child = const TagsView();
        break;
      case "/server":
        child = const ServerView();
        break;
      case "/favorite":
        child = FavoriteScreen();
        break;
      case "/playlist":
        child =
            PlaylistDetailScreen(playlist: routeSettings.arguments as Playlist);
        break;
      case "/search":
        child = const SearchScreen();
        break;
      case "/settings":
        child = const SettingsScreen();
        break;
      case "/settings/log":
        child = const SettingsLogView();
        break;
      default:
        throw UnimplementedError(
            "You've entered an unknown area! This should not happen.");
    }

    return AnnixPage(
      child: child,
      name: routeSettings.name,
      arguments: routeSettings.arguments,
      key: Key(routeSettings.name!) as LocalKey,
    );
  }

  static AnnixRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is AnnixRouterDelegate, 'Delegate type must match');
    return delegate as AnnixRouterDelegate;
  }
}
