import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/playlist_controller.dart';
import 'package:annix/pages/playing.dart';
import 'package:annix/pages/root.dart';
import 'package:annix/services/global.dart';
import 'package:annix/pages/search.dart';
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
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => RootScreen(),
          binding: RootScreenBinding(),
        ),
        GetPage(
          name: '/playing',
          page: () => PlayingScreen(),
        ),
        GetPage(
          name: '/search',
          page: () => SearchScreen(),
        ),
      ],
    );
  }
}
