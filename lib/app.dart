import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/playlist_controller.dart';
import 'package:annix/pages/album_list.dart';
import 'package:annix/services/global.dart';
import 'package:annix/views/home.dart';
import 'package:annix/views/search.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PlayingController(service: Global.audioService));
    Get.put(Global.annil);
    Get.put(PlaylistController(service: Global.audioService));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(255, 184, 253, 127),
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: '/home',
      getPages: [
        GetPage(
          name: '/home',
          page: () => AnnixHome(),
          binding: HomeBinding(),
        ),
        GetPage(
          name: '/search',
          page: () => SearchScreen(),
          transitionDuration: Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  var currentIndex = 0.obs;

  final pages = <String>['/home', '/albums', '/settings'];

  void changePage(int index) {
    currentIndex.value = index;
    Get.toNamed(pages[index], id: 1, preventDuplicates: false);
  }

  Route? onGenerateRoute(RouteSettings settings) {
    print(settings);
    if (settings.name == '/home')
      return GetPageRoute(
        settings: settings,
        page: () => HomeScreen(),
        transition: Transition.fadeIn,
        curve: Curves.easeInQuint,
        transitionDuration: Duration(milliseconds: 300),
        // binding: HistoryBinding(),
      );

    if (settings.name == '/albums')
      return GetPageRoute(
        settings: settings,
        page: () => AlbumList(),
        transition: Transition.fadeIn,
        curve: Curves.easeInQuint,
        transitionDuration: Duration(milliseconds: 300),
      );

    if (settings.name == '/settings')
      return GetPageRoute(
        settings: settings,
        page: () => Text('/settings'),
        transition: Transition.fadeIn,
        curve: Curves.easeInQuint,
        transitionDuration: Duration(milliseconds: 300),
        // binding: SettingsBinding(),
      );

    return null;
  }
}

class AnnixHome extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text("Light / Dark Theme"),
              onTap: () {
                Get.changeThemeMode(
                  Get.isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            )
          ],
        ),
      ),
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: '/home',
        onGenerateRoute: controller.onGenerateRoute,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {},
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          // elevation: 0,
          // backgroundColor: Get.theme.primaryColor.withOpacity(0.6),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.album),
              label: 'Albums',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          selectedIndex: controller.currentIndex.value,
          onDestinationSelected: controller.changePage,
        ),
      ),
    );
  }
}

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        double sensitivity = 360;

        print(details.primaryVelocity);
        if (details.primaryVelocity! > sensitivity) {
          // Right Swipe, prev
          print("Right Swipe, prev");
          playing.service.previous();
        } else if (details.primaryVelocity! < -sensitivity) {
          // Left Swipe, next
          print("Left Swipe, next");
          playing.service.next();
        }
      },
      child: Container(
        height: 64,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Obx(
              () => Global.annil.cover(
                  albumId: playing.state.value.track?.track.albumId ?? "TODO"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => Text(
                  "${playing.state.value.track?.info.title}",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            RepeatButton(
              initial: Global.audioService.repeatMode,
              onRepeatModeChange: (mode) {
                Global.audioService.repeatMode = mode;
              },
            ),
            Obx(
              () => playing.status.value == PlayingStatus.loading
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(playing.status.value == PlayingStatus.playing
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () async {
                        if (playing.status.value == PlayingStatus.playing) {
                          playing.service.pause();
                        } else {
                          playing.service.play();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
