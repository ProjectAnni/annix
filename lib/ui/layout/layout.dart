import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/playing/playing_mobile_blur.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/route/page.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliding_up_panel2/sliding_up_panel2.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AnnixLayout extends HookConsumerWidget {
  final AnnixRouterDelegate router;
  final Widget child;

  static const pages = <String>[
    '/home',
    '/search',
    '/settings',
  ];

  const AnnixLayout({
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
        if (context.isDesktopOrLandscape) {
          return const PlayingDesktopScreen();
        }
        return blur
            ? const PlayingScreenMobileBlur()
            : const PlayingScreenMobile();
      },
    );

    final currentIndex = pages.indexOf(router.currentRoute);
    onDestinationSelected(final index) {
      router.off(
        name: pages[index],
        pageBuilder: fadeTransitionBuilder,
        transitionDuration: const Duration(milliseconds: 250),
      );
    }

    final destinations = [
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
    ];
    final body = Consumer(
      builder: (final context, final ref, final child) {
        final isQueueEmpty =
            ref.watch(playbackProvider.select((final p) => p.queue.isEmpty));
        final showMiniPlayer = context.isDesktopOrLandscape || !isQueueEmpty;
        final miniPlayerHeight = showMiniPlayer
            ? context.isDesktopOrLandscape
                ? DesktopBottomPlayer.height
                : MobileBottomPlayer.height
            : 0.0;
        return Stack(
          children: [
            Positioned.fill(
              bottom: miniPlayerHeight,
              child: child!,
            ),
            if (showMiniPlayer)
              LayoutBuilder(
                builder: (context, constraints) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                      size: Size(constraints.maxWidth, constraints.maxHeight)),
                  child: SlidingUpPanel(
                    controller: router.panelController,
                    renderPanelSheet: false,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    panelBuilder: () {
                      return panel;
                    },
                    collapsed: GestureDetector(
                      onTap: router.openPanel,
                      child: SlotLayout(
                        config: <Breakpoint, SlotLayoutConfig>{
                          Breakpoints.small: SlotLayout.from(
                            key: const Key('Bottom Player Small'),
                            builder: (context) => const MobileBottomPlayer(),
                          ),
                          Breakpoints.mediumAndUp: SlotLayout.from(
                            key: const Key('Bottom Player Medium'),
                            builder: (context) => const DesktopBottomPlayer(),
                          ),
                        },
                      ),
                    ),
                    minHeight: miniPlayerHeight,
                    maxHeight: panelMaxSize,
                    onPanelSlide: (pos) => positionState.value = pos,
                  ),
                ),
              )
          ],
        );
      },
      child: child,
    );
    final root = AdaptiveLayout(
      primaryNavigation: SlotLayout(config: <Breakpoint, SlotLayoutConfig>{
        Breakpoints.mediumAndUp: SlotLayout.from(
          key: const Key('Primary Navigation Medium'),
          builder: (context) => AdaptiveScaffold.standardNavigationRail(
            leading: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Consumer(builder: (context, ref, child) {
                final info = ref.watch(annivProvider.select((v) => v.info));
                if (info == null) {
                  return TextButton(
                    child: Text(t.server.login),
                    onPressed: () {
                      ref.read(routerProvider).to(name: '/login');
                    },
                  );
                }

                return FloatingActionButton(
                  elevation: 2,
                  child: CircleAvatar(
                    child: Text(info.user.nickname.substring(0, 1)),
                  ),
                  onPressed: () {
                    ref.read(routerProvider).to(name: '/server');
                  },
                );
              }),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Consumer(
                  builder: (final context, final ref, final child) {
                    final router = ref.watch(routerProvider);
                    return IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed:
                          router.mayPop() ? () => router.popRoute() : null,
                    );
                  },
                ),
              ),
            ),
            labelType: NavigationRailLabelType.all,
            selectedIndex: currentIndex >= 0 ? currentIndex : null,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
        ),
      }),
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Body Small'),
            builder: (context) => body,
          ),
          Breakpoints.mediumAndUp: SlotLayout.from(
            key: const Key('Body Medium'),
            builder: (context) => Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: body,
            ),
          ),
        },
      ),
      bottomNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Bottom Navigation Small'),
            builder: (context) => SizedBox(
              height: currentHeight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: opacity,
                child: AdaptiveScaffold.standardBottomNavigationBar(
                  currentIndex: currentIndex,
                  onDestinationSelected: onDestinationSelected,
                  destinations: destinations,
                ),
              ),
            ),
          ),
        },
      ),
    );

    return Navigator(
      pages: [MaterialPage(child: Material(child: root))],
      onPopPage: (final route, final result) {
        return false;
      },
      observers: [ThemePopObserver(ref.read(themeProvider))],
    );
  }
}
