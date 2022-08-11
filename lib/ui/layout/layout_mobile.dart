import 'package:annix/services/global.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/bottom_player/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:we_slide/we_slide.dart';

class AnnixLayoutMobile extends AnnixLayout {
  final AnnixRouterDelegate router;
  final Widget child;

  static const pages = <String>[
    '/home',
    '/tags',
    '/server',
  ];

  const AnnixLayoutMobile({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final double panelMaxSize = MediaQuery.of(context).size.height;

    final root = Scaffold(
      body: Selector<PlayerService, bool>(
        selector: (context, player) => player.playing != null,
        builder: (context, isPlaying, child) {
          return WeSlide(
            controller: Global.mobileWeSlideController,
            parallax: true,
            hideAppBar: true,
            hideFooter: true,
            body: Material(child: child),
            panelMinSize: 80 + (isPlaying ? 60 : 0),
            panelMaxSize: panelMaxSize,
            panelHeader: GestureDetector(
              onTap: () => Global.mobileWeSlideController.show(),
              child: const MobileBottomPlayer(),
            ),
            panel: PlayingMobileScreen(),
            footerHeight: 80 + 24,
            footer: (() {
              final route = router.currentRoute;
              final selectedIndex =
                  pages.contains(route) ? pages.indexOf(route) : null;
              if (selectedIndex == null) {
                return const SizedBox.shrink();
              }

              return SafeArea(
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    router.off(name: pages[index]);
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.casino_outlined),
                      label: I18n.HOME.tr,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.local_offer_outlined),
                      label: I18n.CATEGORY.tr,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.dns_outlined),
                      label: I18n.SERVER.tr,
                    ),
                  ],
                ),
              );
            })(),
          );
        },
        child: child,
      ),
      // floatingActionButton: Builder(
      //   builder: (context) {
      //     return Consumer<PlayerService>(
      //       builder: (context, player, child) {
      //         return Padding(
      //           padding: EdgeInsets.only(
      //             bottom: player.playing != null ? 48.0 : 0.0,
      //           ),
      //           child: child,
      //         );
      //       },
      //       child: FloatingActionButton(
      //         onPressed: () {
      //           router.to(name: "/search");
      //         },
      //         isExtended: true,
      //         child: const Icon(Icons.search),
      //       ),
      //     );
      //   },
      // ),
    );

    return Navigator(
      pages: [MaterialPage(child: root)],
      onPopPage: (route, result) {
        return false;
      },
    );
  }
}
