import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/services/global.dart';
import 'package:annix/views/search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(primarySwatch: Colors.blueGrey);
    final darkTheme = ThemeData(brightness: Brightness.dark);

    return GetBuilder<GetMaterialController>(
      init: Get.rootController,
      initState: (_) {
        Get.config(
          enableLog: Get.isLogEnable,
          defaultTransition: Get.defaultTransition,
          defaultOpaqueRoute: Get.isOpaqueRouteDefault,
          defaultPopGesture: Get.isPopGestureEnable,
          defaultDurationTransition: Get.defaultTransitionDuration,
        );
      },
      builder: (_) {
        return MaterialApp(
          theme: _.theme ?? theme,
          darkTheme: _.darkTheme ?? darkTheme,
          themeMode: _.themeMode,
          scaffoldMessengerKey: _.scaffoldMessengerKey,
          home: AnnixMain(),
        );
      },
    );
  }
}

class AnnixMain extends StatelessWidget {
  const AnnixMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.put(PlayingController());

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
        key: Get.key,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return GetPageRoute(page: () => AnnixHome());
          } else if (settings.name == '/second') {
            return GetPageRoute(
              page: () => Center(
                child: Scaffold(
                  appBar: AppBar(
                    title: Text("Main"),
                  ),
                  body: Center(child: Text("second")),
                ),
              ),
            );
          } else {
            return GetPageRoute(page: () => Container());
          }
        },
      ),
      bottomNavigationBar: BottomPlayer(),
    );
  }
}

class AnnixHome extends StatelessWidget {
  const AnnixHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: 48,
          title: const TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            tabs: [
              Tab(child: Text("Playlists")),
              Tab(child: Text("Albums")),
              Tab(child: Text("Categories")),
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Get.to(
                  () => SearchScreen(),
                  transition: Transition.fade,
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Builder(builder: (context) {
              print(1);
              return Icon(Icons.directions_car);
            }),
            Builder(builder: (context) {
              print(2);
              return Icon(Icons.directions_transit);
            }),
            Builder(builder: (context) {
              print(3);
              return Icon(Icons.directions_bike);
            }),
          ],
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Global.annil
            .cover(albumId: playing.state.value.track?.track.albumId ?? "123")),
        Obx(() => Text("${playing.state.value.track?.info.title}")),
        Obx(
          () => playing.state.value.status == PlayingStatus.loading
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(playing.state.value.status == PlayingStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () async {},
                ),
        ),
      ],
    );
  }
}
