import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/bottom_player/bottom_player.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// F |
///   |
///   |
/// n |
/// a |       bodypage
/// v |
///   |
///   |
/// __|______________________
///            player
///
class AnnixLayoutDesktop extends AnnixLayout {
  final AnnixRouterDelegate router;
  final Widget child;

  const AnnixLayoutDesktop({
    super.key,
    required this.child,
    required this.router,
  });

  static const pages = <String>[
    '/home',
    '/playing',
    '/tags',
    '/server',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                (() {
                  final route = router.currentRoute;
                  final selectedIndex =
                      pages.indexOf(route) == -1 ? null : pages.indexOf(route);

                  return NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      router.off(name: pages[index]);
                    },
                    labelType: NavigationRailLabelType.all,
                    leading: FloatingActionButton(
                      child: Icon(Icons.search_outlined),
                      onPressed: () {
                        router.to(name: "/search");
                      },
                    ),
                    groupAlignment: -0.7,
                    destinations: <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.casino_outlined),
                        label: Text(I18n.HOME.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.music_note_outlined),
                        selectedIcon: Icon(Icons.music_note_sharp),
                        label: Text(I18n.PLAYING.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.local_offer_outlined),
                        label: Text(I18n.CATEGORY.tr),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.dns_outlined),
                        label: Text(I18n.SERVER.tr),
                      ),
                    ],
                  );
                })(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DesktopBottomPlayer(),
        ],
      ),
    );
  }
}
