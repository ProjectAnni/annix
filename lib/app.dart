import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/initialize_controller.dart';
import 'package:annix/controllers/offline_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/pages/playing.dart';
import 'package:annix/pages/root.dart';
import 'package:annix/pages/search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // network
    final network = NetworkController();
    Get.put(network);
    // playing
    Get.put(PlayingController());

    // annil & anniv
    final annil = AnnilController();
    Get.put(annil);
    final anniv = AnnivController();
    Get.put(anniv);

    // initialization awaiter
    ever(
        InitializeController([
          network.init().then((_) => Future.wait([annil.init(), anniv.init()]))
        ]).done, (value) {
      Get.offAllNamed('/');
    });

    return GetMaterialApp(
      title: "Annix",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(255, 184, 253, 127),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Color.fromARGB(255, 184, 253, 127),
      ),
      initialRoute: '/initialize',
      getPages: [
        GetPage(
          name: '/initialize',
          page: () => Scaffold(
            body: Builder(builder: (context) {
              return Center(
                child: FlutterLogo(),
              );
            }),
          ),
        ),
        GetPage(
          name: '/',
          page: () => RootScreen(),
          binding: RootScreenBinding(),
          transition: Transition.fadeIn,
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
