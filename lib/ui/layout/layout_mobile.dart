import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/playing/playing_mobile_blur.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/route/page.dart';
import 'package:annix/utils/anni_weslide_controller.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:we_slide/we_slide.dart';
import 'package:annix/i18n/strings.g.dart';

class AnnixLayoutMobile extends ConsumerWidget {
  static final slideFooterController = AnniWeSlideController(initial: true);

  final AnnixRouterDelegate router;
  final Widget child;

  static const pages = <String>[
    '/home',
    '/tags',
    '/settings',
  ];

  const AnnixLayoutMobile({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final double panelMaxSize = MediaQuery.of(context).size.height;

    final root = Scaffold(
      body: Consumer(
        builder: (final context, final ref, final child) {
          final delegate = ref.watch(routerProvider);
          final isMainPage = pages.contains(delegate.currentRoute);
          if (!isMainPage) {
            slideFooterController.hide();
          } else {
            slideFooterController.show();
          }

          final isQueueEmpty =
              ref.watch(playbackProvider.select((final p) => p.queue.isEmpty));
          final isPlaying = ref
              .watch(playbackProvider.select((final p) => p.playing != null));
          return WeSlide(
            controller: router.slideController,
            footerController: slideFooterController,
            parallax: true,
            hideAppBar: true,
            hideFooter: true,
            panelBorderRadiusBegin: 12,
            panelBorderRadiusEnd: 0,
            backgroundColor: Colors.transparent,
            body: Material(child: child),
            panelMinSize: (isQueueEmpty
                    ? 0
                    : MobileBottomPlayer.height /* panel header*/) +
                80 /* footer */,
            panelMaxSize: panelMaxSize,
            isUpSlide: isPlaying,
            panelHeader: GestureDetector(
              onTap: () {
                if (isPlaying) {
                  router.slideController.show();
                }
              },
              child: const MobileBottomPlayer(),
            ),
            panel: ValueListenableBuilder(
              valueListenable: ref.read(settingsProvider).blurPlayingPage,
              builder: (final context, final bool blur, final child) {
                return blur
                    ? const PlayingScreenMobileBlur()
                    : const PlayingScreenMobile();
              },
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
                  onDestinationSelected: (final index) {
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
                      icon: const Icon(Icons.settings_outlined),
                      label: t.settings.settings,
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
      onPopPage: (final route, final result) {
        return false;
      },
      observers: [ThemePopObserver(ref.read(themeProvider))],
    );
  }
}
