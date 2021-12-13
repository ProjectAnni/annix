import 'package:annix/services/platform.dart';
import 'package:annix/widgets/bottom_playbar.dart';
import 'package:annix/widgets/draggable_appbar.dart';
import 'package:annix/widgets/navigator.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class HomePageDesktop extends StatefulWidget {
  final Widget child;

  const HomePageDesktop({Key? key, required this.child}) : super(key: key);

  @override
  _HomePageDesktopState createState() => _HomePageDesktopState();
}

class _HomePageDesktopState extends State<HomePageDesktop> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: DraggableAppBar(
        title: Text("Annix"),
        trailingActions: AnniPlatform.isDesktop && !AnniPlatform.isMacOS
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
                // TODO: Window <-> Full
                SquareIconButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    appWindow.close();
                  },
                )
              ]
            : [],
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
                  child: widget.child,
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
  }
}
