import 'package:annix/pages/home_desktop.dart';
import 'package:annix/pages/setup.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

// TODO: https://docs.flutter.dev/cookbook/effects/nested-nav
class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var initialRoute = '/home_desktop';
    if (Global.needSetup) {
      initialRoute = '/setup';
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnnilPlaylist(service: Global.audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnilPlayState(service: Global.audioService),
        )
      ],
      child: PlatformApp(
        debugShowCheckedModeBanner: false,
        title: 'Annix',
        // theme: ThemeData(
        //   // primarySwatch: Colors.teal,
        //   brightness: Brightness.dark,
        // ),
        initialRoute: initialRoute,
        routes: {
          '/home_desktop': (context) => WindowBorder(
                color: Color(0xFF805306),
                width: 4,
                child: HomePageDesktop(),
              ),
          '/setup': (context) => AnnixSetup(),
          '/': (context) => Container(),
        },
      ),
    );
  }
}
