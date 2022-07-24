import 'package:annix/pages/desktop/playing_desktop.dart';
import 'package:annix/pages/root/albums.dart';
import 'package:annix/pages/root/home.dart';
import 'package:annix/pages/root/playlists.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/pages/root/tags.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/ui/page/page.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class AnnixBodyPageRouter extends GetxController {
  static AnnixBodyPageRouter get to => Get.find();

  final Map<String, AnnixPage> pages = new Map();

  String? get currentPage => _currentPage;
  String _currentPage;

  AnnixBodyPageRouter(String initialPage) : _currentPage = initialPage {
    this.registerPages([
      AnnixPage.wrap(route: "/home", page: () => HomeView()),
      AnnixPage.wrap(route: "/albums", page: () => AlbumsView()),
      AnnixPage.wrap(route: "/tags", page: () => TagsView()),
      AnnixPage.wrap(route: "/playlists", page: () => PlaylistsView()),
      AnnixPage.wrap(route: "/server", page: () => ServerView()),
      AnnixPage.wrap(
        route: "/settings",
        page: () => SettingsScreen(automaticallyImplyLeading: false),
      ),
      AnnixPage.wrap(route: "/playing", page: () => PlayingDesktopScreen()),
    ]);
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
}
