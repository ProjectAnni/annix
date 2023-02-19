import 'package:annix/global.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/playing/playing_mobile_blur.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/route/page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_slide/we_slide.dart';
import 'package:annix/i18n/strings.g.dart';

class AnnixLayoutMobile extends StatelessWidget {
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
      body: Selector2<PlaybackService, AnnixRouterDelegate, List<bool>>(
        selector: (context, player, delegate) {
          final isQueueEmpty = player.queue.isEmpty;
          final isPlaying = player.playing != null;
          final isMainPage = pages.contains(delegate.currentRoute);
          return [isQueueEmpty, isPlaying, isMainPage];
        },
        builder: (context, result, child) {
          final isQueueEmpty = result[0];
          final isPlaying = result[1];
          final isMainPage = result[2];
          if (!isMainPage) {
            Global.mobileWeSlideFooterController.hide();
          } else {
            Global.mobileWeSlideFooterController.show();
          }

          return WeSlide(
            controller: Global.mobileWeSlideController,
            footerController: Global.mobileWeSlideFooterController,
            parallax: true,
            hideAppBar: true,
            hideFooter: true,
            panelBorderRadiusBegin: 12,
            panelBorderRadiusEnd: 0,
            backgroundColor: Colors.transparent,
            body: Material(child: child),
            panelMinSize:
                (isQueueEmpty ? 0 : 60 /* panel header*/) + 80 /* footer */,
            panelMaxSize: panelMaxSize,
            isUpSlide: isPlaying,
            panelHeader: GestureDetector(
              onTap: () {
                if (isPlaying) {
                  Global.mobileWeSlideController.show();
                }
              },
              child: const MobileBottomPlayer(),
            ),
            panel: ValueListenableProvider.value(
              value: Global.settings.blurPlayingPage,
              updateShouldNotify: (old, value) => true,
              child: Builder(
                builder: (context) {
                  final blur = context.watch<bool>();
                  return blur
                      ? const PlayingScreenMobileBlur()
                      : const PlayingScreenMobile();
                },
              ),
            ),
            footerHeight: 80,
            footer: (() {
              final route = router.currentRoute;
              final selectedIndex =
                  pages.contains(route) ? pages.indexOf(route) : 0;

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(padding: EdgeInsets.zero),
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    router.off(
                      name: pages[index],
                      pageBuilder: fadeTransitionBuilder,
                      transitionDuration: const Duration(milliseconds: 250),
                    );
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.casino_outlined),
                      label: t.home,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.local_offer_outlined),
                      label: t.category,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.dns_outlined),
                      label: t.server.server,
                    ),
                  ],
                ),
              );
            })(),
          );
        },
        child: child,
      ),
      resizeToAvoidBottomInset: false,
    );

    return Navigator(
      pages: [MaterialPage(child: root)],
      onPopPage: (route, result) {
        return false;
      },
    );
  }
}
