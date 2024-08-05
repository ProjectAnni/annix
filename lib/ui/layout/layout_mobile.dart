import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/playing/playing_mobile_blur.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/route/page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnnixLayoutMobile extends HookConsumerWidget {
  final AnnixRouterDelegate router;
  final Widget child;

  static const pages = <String>[
    '/home',
    '/search',
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

    final positionState = useState(0.0);
    final opacity = 1 - positionState.value;

    final bottomNavHeight = 80.0 + MediaQuery.of(context).padding.bottom;
    final currentHeight = bottomNavHeight * (1 - positionState.value);

    final panel = ValueListenableBuilder(
      valueListenable: ref.read(settingsProvider).blurPlayingPage,
      builder: (final context, final bool blur, final child) {
        return blur
            ? const PlayingScreenMobileBlur()
            : const PlayingScreenMobile();
      },
    );
    final root = Scaffold(
      body: Consumer(
        builder: (final context, final ref, final child) {
          final isQueueEmpty =
              ref.watch(playbackProvider.select((final p) => p.queue.isEmpty));
          final showMiniPlayer = !isQueueEmpty;
          return Stack(
            children: [
              Positioned.fill(
                bottom: showMiniPlayer ? MobileBottomPlayer.height : 0,
                child: child!,
              ),
              if (showMiniPlayer)
                SlidingUpPanel(
                  controller: router.panelController,
                  renderPanelSheet: false,
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  panelBuilder: () {
                    return panel;
                  },
                  collapsed: GestureDetector(
                    child: const MobileBottomPlayer(),
                    onTap: () {
                      router.panelController.open();
                    },
                  ),
                  minHeight: MobileBottomPlayer.height,
                  maxHeight: panelMaxSize,
                  onPanelSlide: (pos) => positionState.value = pos,
                ),
            ],
          );
        },
        child: child,
      ),
      bottomNavigationBar: SizedBox(
        height: currentHeight,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: opacity,
          child: NavigationBar(
            height: bottomNavHeight,
            selectedIndex:
                pages.indexOf(router.currentRoute).clamp(0, pages.length),
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
                icon: const Icon(Icons.search),
                label: t.search,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                label: t.settings.settings,
              ),
            ],
          ),
        ),
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
