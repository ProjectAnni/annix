import 'package:annix/providers.dart';
import 'package:annix/services/theme.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/page/playing/playing_mobile_blur.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/route/page.dart';
import 'package:annix/ui/widgets/slide_up.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

  static Builder standardBottomNavigationBar({
    required List<NavigationDestination> destinations,
    int? currentIndex,
    double iconSize = 24,
    ValueChanged<int>? onDestinationSelected,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final NavigationBarThemeData currentNavBarTheme =
            NavigationBarTheme.of(context);
        return NavigationBarTheme(
          data: currentNavBarTheme.copyWith(
            iconTheme: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) {
                return currentNavBarTheme.iconTheme
                        ?.resolve(states)
                        ?.copyWith(size: iconSize) ??
                    IconTheme.of(context).copyWith(size: iconSize);
              },
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).removePadding(removeTop: true),
            child: NavigationBar(
              selectedIndex: currentIndex ?? 0,
              destinations: destinations,
              onDestinationSelected: onDestinationSelected,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              // hide the indicator if the currentIndex is null
              indicatorColor: currentIndex == null ? Colors.transparent : null,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final double panelMaxSize = MediaQuery.of(context).size.height;
    final heroC = HeroController();

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

    final currentIndex = pages.contains(router.currentRoute)
        ? pages.indexOf(router.currentRoute)
        : null;
    onDestinationSelected(final index) {
      if (index >= pages.length) {
        router.popRoute();
        return;
      }

      router.off(
        name: pages[index],
        pageBuilder: fadeThroughTransitionBuilder,
        // transitionDuration: const Duration(milliseconds: 250),
      );
    }

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_filled),
        label: t.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.search),
        label: t.search,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
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
              SlidingUpPanel(
                controller: router.panelController,
                borderRadius: BorderRadius.circular(8),
                panel: panel,
                isDraggable: context.isMobileOrPortrait,
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
              )
          ],
        );
      },
      child: child,
    );
    final root = AdaptiveLayout(
      internalAnimations: false,
      primaryNavigation: SlotLayout(config: <Breakpoint, SlotLayoutConfig>{
        Breakpoints.mediumAndUp: SlotLayout.from(
          key: const Key('Primary Navigation Medium'),
          builder: (context) => AdaptiveScaffold.standardNavigationRail(
            padding: EdgeInsets.zero,
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
            labelType: NavigationRailLabelType.none,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              ...destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: d.icon,
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
              NavigationRailDestination(
                icon: const Icon(Icons.arrow_back),
                label: const Text('back'),
                disabled: !router.mayPop(),
              )
            ],
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
                child: standardBottomNavigationBar(
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
      observers: [
        ThemePopObserver(ref.read(themeProvider)),
        heroC,
      ],
    );
  }
}
