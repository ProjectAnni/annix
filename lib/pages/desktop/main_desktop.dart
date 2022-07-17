import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/desktop/playing_desktop.dart';
import 'package:annix/pages/root/albums.dart';
import 'package:annix/pages/root/home.dart';
import 'package:annix/pages/root/playlists.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/pages/root/tags.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/pages/desktop/desktop_bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopMainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainDesktopScreenController());
  }
}

class MainDesktopScreenController extends GetxController {
  static MainDesktopScreenController get to => Get.find();

  var currentIndex = 0.obs;

  final pages = <String>[
    '/playing',
    '/home',
    '/tags',
    '/playlists',
    '/server',
  ];

  void changePage(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      Get.toNamed(pages[index], id: 1);
    }
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == '/home')
      return GetPageRoute(
        settings: settings,
        page: () => HomeView(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/albums')
      return GetPageRoute(
        settings: settings,
        page: () => AlbumsView(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/tags')
      return GetPageRoute(
        settings: settings,
        page: () => TagsView(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/playlists')
      return GetPageRoute(
        settings: settings,
        page: () => PlaylistsView(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/server')
      return GetPageRoute(
        settings: settings,
        page: () => ServerView(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/settings')
      return GetPageRoute(
        settings: settings,
        page: () => SettingsScreen(automaticallyImplyLeading: false),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    if (settings.name == '/playing')
      return GetPageRoute(
        settings: settings,
        page: () => PlayingDesktopScreen(),
        transition: Transition.fadeIn,
        curve: Curves.easeIn,
      );

    return null;
  }
}

class MainDesktopScreen extends GetView<MainDesktopScreenController> {
  const MainDesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                Obx(() {
                  return NavigationRail(
                    selectedIndex: controller.currentIndex.value,
                    onDestinationSelected: controller.changePage,
                    labelType: NavigationRailLabelType.all,
                    leading: FloatingActionButton(
                      child: Icon(Icons.search_outlined),
                      onPressed: () {
                        //
                      },
                    ),
                    groupAlignment: -0.7,
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.music_note_outlined),
                        selectedIcon: Icon(Icons.music_note_sharp),
                        label: Text(I18n.PLAYING.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.casino_outlined),
                        label: Text(I18n.HOME.tr),
                      ),
                      // NavigationRailDestination(
                      //   icon: Icon(Icons.album_outlined),
                      //   label: Text(I18n.ALBUMS.tr),
                      // ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_offer_outlined),
                        label: Text(I18n.CATEGORY.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.queue_music_outlined),
                        label: Text(I18n.PLAYLISTS.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.dns_outlined),
                        label: Text(I18n.SERVER.tr),
                      ),
                    ],
                  );
                }),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Navigator(
                            key: Get.nestedKey(1),
                            initialRoute: '/playing',
                            onGenerateRoute: controller.onGenerateRoute,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DesktopBottomPlayer(),
        ],
      ),
    );
  }
}
