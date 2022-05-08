import 'package:annix/pages/playing/queue.dart';
import 'package:annix/pages/root/albums.dart';
import 'package:annix/pages/root/home.dart';
import 'package:annix/pages/root/playlists.dart';
import 'package:annix/pages/root/server.dart';
import 'package:annix/widgets/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RootScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RootScreenController());
  }
}

class RootScreenController extends GetxController {
  static RootScreenController get to => Get.find();

  var currentIndex = 0.obs;

  final pages = <String>['/home', '/albums', '/playlists', '/server'];

  void changePage(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      Get.toNamed(pages[index], id: 1, preventDuplicates: true);
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

    return null;
  }
}

class RootScreen extends GetView<RootScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Drawer Header'),
            ),
            // TODO: remote this, it's just for testing
            ListTile(
              leading: Icon(Icons.playlist_add),
              title: Text("Playlist"),
              onTap: () {
                Get.to(
                  () => Scaffold(
                    appBar: AppBar(),
                    body: PlayingQueue(),
                  ),
                  duration: Duration(milliseconds: 300),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text("Light / Dark Theme"),
              onTap: () {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Navigator(
            key: Get.nestedKey(1),
            initialRoute: '/home',
            onGenerateRoute: controller.onGenerateRoute,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: BottomPlayer(),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.search),
      //   onPressed: () {
      //     Get.toNamed('/search');
      //   },
      //   isExtended: true,
      // ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.casino_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.album_outlined),
              label: 'Albums',
            ),
            NavigationDestination(
              icon: Icon(Icons.queue_music_outlined),
              label: 'Playlists',
            ),
            NavigationDestination(
              icon: Icon(Icons.dns_outlined),
              label: 'Server',
            ),
          ],
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
        ),
      ),
    );
  }
}
