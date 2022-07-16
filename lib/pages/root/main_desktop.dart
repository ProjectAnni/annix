import 'package:annix/controllers/player_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/playing/playing_desktop.dart';
import 'package:annix/pages/root/albums.dart';
import 'package:annix/pages/root/home.dart';
import 'package:annix/pages/root/playlists.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/pages/settings/settings.dart';
import 'package:annix/widgets/bottom_player.dart';
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
    '/home',
    '/albums',
    '/playlists',
    '/server',
    '/settings'
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
    RxBool extended = false.obs;

    return Scaffold(
      body: Row(
        children: <Widget>[
          Obx(() {
            return NavigationRail(
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changePage,
              extended: extended.value,
              labelType: extended.value
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: IconButton(
                icon: Icon(Icons.menu),
                padding: EdgeInsets.symmetric(vertical: 16),
                onPressed: () {
                  extended.value = !extended.value;
                },
              ),
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: Icon(Icons.casino_outlined),
                  label: Text(I18n.HOME.tr),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.album_outlined),
                  label: Text(I18n.ALBUMS.tr),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.queue_music_outlined),
                  label: Text(I18n.PLAYLISTS.tr),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.dns_outlined),
                  label: Text(I18n.SERVER.tr),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  label: Text(I18n.SETTINGS.tr),
                ),
              ],
            );
          }),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constriants) => Container(
                width: constriants.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GetBuilder<PlayerController>(
                      builder: (player) => SizedBox(
                        height: player.playing != null
                            ? constriants.maxHeight - 81
                            : constriants.maxHeight,
                        child: Navigator(
                          key: Get.nestedKey(1),
                          initialRoute: '/home',
                          onGenerateRoute: controller.onGenerateRoute,
                        ),
                      ),
                    ),
                    GetBuilder<PlayerController>(
                      builder: (player) => player.playing != null
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(thickness: 1, height: 1),
                                BottomPlayer(
                                  id: 1,
                                  height: 80,
                                )
                              ],
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
