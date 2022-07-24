import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/desktop/desktop_bottom_player.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/route/route.dart';
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
  const AnnixLayoutDesktop({super.key});

  static const pages = <String>[
    '/playing',
    '/home',
    '/tags',
    '/playlists',
    '/server',
  ];

  static const INITIAL_DESKTOP_PAGE = "/playing";

  onDestinationSelected(int index) {
    Get.offNamed(pages[index], id: 1);
  }

  @override
  Widget build(BuildContext context) {
    final AnnixBodyPageRouter router =
        Get.put(AnnixBodyPageRouter(INITIAL_DESKTOP_PAGE));

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: <Widget>[
                GetBuilder<AnnixBodyPageRouter>(
                  builder: (router) {
                    final route = router.currentPage;
                    final selectedIndex = pages.indexOf(route) == -1
                        ? null
                        : pages.indexOf(route);

                    return NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: onDestinationSelected,
                      labelType: NavigationRailLabelType.all,
                      leading: FloatingActionButton(
                        child: Icon(Icons.search_outlined),
                        onPressed: () {
                          //
                        },
                      ),
                      groupAlignment: -0.7,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: Icon(Icons.music_note_outlined),
                          selectedIcon: Icon(Icons.music_note_sharp),
                          label: Text(I18n.PLAYING.tr),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.casino_outlined),
                          label: Text(I18n.HOME.tr),
                        ),
                        // NavigationRailDestination(
                        //   icon: Icon(Icons.album_outlined),
                        //   label: Text(I18n.ALBUMS.tr),
                        // ),
                        NavigationRailDestination(
                          icon: Icon(Icons.local_offer_outlined),
                          label: Text(I18n.CATEGORY.tr),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.queue_music_outlined),
                          label: Text(I18n.PLAYLISTS.tr),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.dns_outlined),
                          label: Text(I18n.SERVER.tr),
                        ),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Navigator(
                            key: Get.nestedKey(1),
                            initialRoute: INITIAL_DESKTOP_PAGE,
                            onGenerateRoute: router.onGenerateRoute,
                          ),
                        ),
                      ),
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
