import 'package:annix/pages/album_list.dart';
import 'package:annix/pages/playlist.dart';
import 'package:annix/pages/search.dart';
import 'package:annix/pages/settings.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/services/route.dart';
import 'package:annix/utils/platform_icons.dart';
import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart'
    show PlatformScaffold, platformPageRoute;
import 'package:provider/provider.dart';

class HomePageDesktop extends StatefulWidget {
  const HomePageDesktop({Key? key}) : super(key: key);

  @override
  _HomePageDesktopState createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnnixDesktopRouter(),
      builder: (context, child) {
        return PlatformScaffold(
          iosContentPadding: true,
          appBar: DraggableAppBar(
            title: Text("Annix"),
            trailingActions: [
              SquareIconButton(
                child: Icon(context.icons.search),
                onPressed: () {
                  AnnixDesktopRouter.of(context, listen: false)
                      .pushReplacementNamed(AnnixDesktopRouter.search);
                },
              ),
              SquareIconButton(
                child: Icon(context.icons.settings),
                onPressed: () {
                  AnnixDesktopRouter.of(context, listen: false)
                      .pushReplacementNamed(AnnixDesktopRouter.settings);
                },
              ),
              SquareIconButton(
                child: Icon(context.icons.person),
                onPressed: () {
                  AnnixDesktopRouter.of(context, listen: false)
                      .pushReplacementNamed('/user');
                },
              ),
              ...(AnniPlatform.isDesktop && !AnniPlatform.isMacOS
                  ? [
                      SquareIconButton(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Icon(
                              Icons.minimize,
                            )
                          ],
                        ),
                        onPressed: () {
                          appWindow.minimize();
                        },
                      ),
                      SquareIconButton(
                        child: Icon(Icons.close),
                        onPressed: () {
                          appWindow.close();
                        },
                      ),
                    ]
                  : [])
            ],
          ),
          body: Row(
            children: [
              // TODO: This is Desktop layout, we need another mobile layout
              // TODO: Design a better way to navigate
              // AnnilNavigator(),
              // const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Navigator(
                        key: AnnixDesktopRouter.navigatorKey,
                        onGenerateRoute: (settings) {
                          late Widget page;
                          var name = settings.name;
                          if (name == null || name == '/') {
                            name = AnnixDesktopRouter.albums;
                          }

                          switch (name) {
                            case AnnixDesktopRouter.albums:
                              page = AlbumList();
                              break;
                            case AnnixDesktopRouter.playlist:
                              page = AnnixPlaylist();
                              break;
                            case AnnixDesktopRouter.settings:
                              page = AnnixSettings();
                              break;
                            case AnnixDesktopRouter.search:
                              page = AnnixSearch();
                              break;
                            case '/user':
                              page = Text('User');
                              break;
                            default:
                              page = Text('Unknown');
                          }

                          return platformPageRoute<Widget>(
                            context: context,
                            builder: (context) => page,
                            settings: settings,
                          );
                        },
                      ),
                    ),
                    // bottom play bar
                    // Use persistentFooterButtons if this issue has been resolved
                    // https://github.com/flutter/flutter/issues/46061
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnniPlatform.isDesktop
                          ? BottomPlayBarDesktop()
                          : BottomPlayerMobile(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
