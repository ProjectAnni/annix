import 'package:annix/pages/album_list.dart';
import 'package:annix/pages/home_desktop.dart';
import 'package:annix/pages/setup.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/cupertino.dart' show CupertinoThemeData;
import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class AnnixApp extends StatefulWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  _AnnixAppState createState() => _AnnixAppState();
}

class _AnnixAppState extends State<AnnixApp> with WidgetsBindingObserver {
  Brightness? _brightness;

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    _brightness = WidgetsBinding.instance?.window.platformBrightness;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) {
      setState(() {
        _brightness = WidgetsBinding.instance?.window.platformBrightness;
      });
    }

    super.didChangePlatformBrightness();
  }

  get materialTheme => ThemeData(brightness: _brightness);
  get cupertinoTheme => CupertinoThemeData(brightness: _brightness);

  @override
  Widget build(BuildContext context) {
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

              var initialRoute = '/home/welcome';
              if (Global.needSetup) {
                initialRoute = '/setup';
              }

              var route = settings.name!;
              if (route == '/') {
                route = initialRoute;
              }

              if (route == '/setup') {
                page = AnnixSetup();
              } else if (route.startsWith('/home')) {
                switch (route.substring('/home'.length)) {
                  case '/welcome':
                    page = HomePageDesktop(child: Text('Welcome'));
                    break;
                  case '/albums':
                    page = HomePageDesktop(
                      child: AlbumList(),
                    );
                    break;
                  default:
                    throw Exception('Unknown route: ${settings.name}');
                }
              } else {
                throw Exception('Unknown route: ${settings.name}');
              }

              return platformPageRoute<Widget>(
                context: context,
                builder: (context) => page,
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
