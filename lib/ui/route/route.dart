import 'package:annix/ui/page/home.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/pages/playlist/playlist_favorite.dart';
import 'package:annix/pages/root/albums.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/pages/root/tags.dart';
import 'package:annix/ui/page/search.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/services/global.dart';
import 'package:annix/ui/page/base/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AnnixBodyPageRouter extends GetxController {
  static AnnixBodyPageRouter get instance => Get.find();

  final Map<String, AnnixPage> pages = new Map();

  String get currentPage => _currentPage;
  String _currentPage;

  AnnixBodyPageRouter(String initialPage) : _currentPage = initialPage {
    this.registerPages([
      AnnixPage.wrap(route: "/home", page: () => HomePage()),
      AnnixPage.wrap(route: "/albums", page: () => AlbumsView()),
      AnnixPage.wrap(route: "/tags", page: () => TagsView()),
      AnnixPage.wrap(route: "/server", page: () => ServerView()),
      AnnixPage.wrap(
        route: "/settings",
        // FIXME
        page: () =>
            SettingsScreen(automaticallyImplyLeading: !Global.isDesktop),
      ),
      AnnixPage.wrap(route: "/favorite", page: () => FavoriteScreen()),
      AnnixPage.wrap(route: "/search", page: () => SearchScreen()),
    ]);

    if (Global.isDesktop) {
      this.registerPages([
        AnnixPage.wrap(route: "/playing", page: () => PlayingDesktopScreen()),
      ]);
    }
  }

  void registerPage(AnnixPage page) {
    this.pages.putIfAbsent(page.route, () => page);
  }

  void registerPages(List<AnnixPage> pages) {
    pages.forEach((page) {
      this.registerPage(page);
    });
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (pages.containsKey(settings.name)) {
      if (_currentPage != settings.name) {
        _currentPage = settings.name!;
        this.refresh();
      }
      return GetPageRoute(
        settings: settings,
        page: () => this.pages[settings.name]!,
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );
    }

    return null;
  }

  static toNamed(String page) {
    final last = instance.currentPage;
    Get.toNamed(page, id: 1)?.then((_) {
      instance._currentPage = last;
      instance.refresh();
    });
  }

  static offNamed(String page) async {
    if (page != instance.currentPage) {
      await Get.offNamed(page, id: 1);
    }
  }

  static to<T>(
    dynamic page, {
    bool? opaque,
    Transition? transition = Transition.fadeIn,
    Curve? curve,
    Duration? duration,
    String? routeName,
    bool fullscreenDialog = false,
    dynamic arguments,
    Bindings? binding,
    bool preventDuplicates = true,
    bool? popGesture,
    double Function(BuildContext context)? gestureWidth,
  }) {
    final last = instance.currentPage;
    instance._currentPage = "";
    instance.refresh();

    return Get.to<T>(
      page,
      id: 1,
      opaque: opaque,
      transition: transition,
      curve: curve,
      duration: duration,
      fullscreenDialog: fullscreenDialog,
      arguments: arguments,
    )?.then((value) {
      instance._currentPage = last;
      instance.refresh();
    });
  }
}
