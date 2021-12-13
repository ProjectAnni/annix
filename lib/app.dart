import 'package:annix/pages/home_desktop.dart';
import 'package:annix/pages/setup.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

// TODO: https://docs.flutter.dev/cookbook/effects/nested-nav
class Annix extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialTheme = ThemeData(
      // primarySwatch: Colors.teal,
      brightness: Brightness.dark,
    );
    var cupertinoTheme = CupertinoThemeData(
      brightness: Brightness.dark,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AnnilPlaylist(service: Global.audioService),
        ),
        ChangeNotifierProvider(
          create: (_) => AnnilPlayState(service: Global.audioService),
        )
      ],
      child: Theme(
        data: materialTheme,
        child: Center(
          child: PlatformApp(
            debugShowCheckedModeBanner: false,
            title: 'Annix',
            onGenerateRoute: (settings) {
              late Widget page;
              print(settings);

              var initialRoute = '/home_desktop';
              if (Global.needSetup) {
                initialRoute = '/setup';
              }

              var route = settings.name;
              if (route == '/') {
                route = initialRoute;
              }

              if (route == '/setup') {
                page = AnnixSetup();
              } else if (route == '/home_desktop') {
                page = HomePageDesktop();
              } else {
                throw Exception('Unknown route: ${settings.name}');
              }

              return MaterialPageRoute<dynamic>(
                builder: (context) {
                  return page;
                },
                settings: settings,
              );
            },
            material: (_, __) => MaterialAppData(
              theme: materialTheme,
            ),
            cupertino: (_, __) => CupertinoAppData(
              theme: cupertinoTheme,
            ),
          ),
        ),
      ),
    );
  }
}
