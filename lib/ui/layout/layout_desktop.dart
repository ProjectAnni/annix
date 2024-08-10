import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:we_slide/we_slide.dart';

class AnnixLayoutDesktop extends ConsumerWidget {
  final AnnixRouterDelegate router;
  final Widget child;

  const AnnixLayoutDesktop({
    super.key,
    required this.child,
    required this.router,
  });

  static const pages = <String>[
    '/home',
    '/tags',
    '/settings',
  ];

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final double panelMaxSize = MediaQuery.of(context).size.height;

    final body = Material(
      child: Row(
        children: <Widget>[
          (() {
            final route = router.currentRoute;
            final selectedIndex =
                pages.contains(route) ? pages.indexOf(route) : null;

            return NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (final index) {
                router.off(name: pages[index]);
              },
              labelType: NavigationRailLabelType.all,
              destinations: <NavigationRailDestination>[
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: Text(t.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.local_offer_outlined),
                  selectedIcon: const Icon(Icons.local_offer),
                  label: Text(t.category),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(t.settings.settings),
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
    );

    final slide = Consumer(
      child: body,
      builder: (final context, final ref, final child) {
        return WeSlide(
          controller: router.slideController,
          hideAppBar: false,
          hideFooter: false,
          parallax: true,
          panelBorderRadiusBegin: 12,
          panelBorderRadiusEnd: 0,
          backgroundColor: Colors.transparent,
          appBarHeight: 60,
          appBar: Material(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Consumer(
                    builder: (final context, final ref, final child) {
                      final router = ref.watch(routerProvider);
                      return IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: router.mayPop()
                            ? () {
                                router.popRoute();
                              }
                            : null,
                      );
                    },
                  ),
                  const Spacer(),
                  Consumer(builder: (final context, final ref, final child) {
                    final info =
                        ref.watch(annivProvider.select((final v) => v.info));
                    return SizedBox(
                      width: 360,
                      child: HomeAppBar(padding: EdgeInsets.zero, info: info),
                    );
                  }),
                ],
              ),
            ),
          ),
          body: child!,
          panelMinSize: 0,
          panelMaxSize: panelMaxSize,
          isUpSlide: false,
          panel: const PlayingDesktopScreen(),
          footerHeight: DesktopBottomPlayer.height,
          footer: DesktopBottomPlayer(
            onClick: () {
              final isPlaying =
                  ref.read(playbackProvider).playing.source != null;
              if (isPlaying) {
                if (router.slideController.isOpened) {
                  router.slideController.hide();
                } else {
                  router.slideController.show();
                }
              }
            },
          ),
        );
      },
    );

    final root = Scaffold(body: SafeArea(child: slide));

    return Navigator(
      pages: [MaterialPage(child: root)],
      onPopPage: (final route, final result) {
        return false;
      },
      observers: [ThemePopObserver(ref.read(themeProvider))],
    );
  }
}
