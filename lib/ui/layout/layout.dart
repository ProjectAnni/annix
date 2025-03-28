import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/page/playing/playing_mobile.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/ui/widgets/slide_up.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LayoutTopSafeArea extends StatelessWidget {
  final Widget child;
  const LayoutTopSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      if (context.isMobileOrPortrait) {
        return Padding(
          padding: const EdgeInsets.only(top: 24),
          child: child,
        );
      }
      return child;
    }
    return child;
  }
}

class AnnixLayout extends HookConsumerWidget {
  final Widget child;

  static const pages = <String>[
    '/home',
    '/music',
  ];

  const AnnixLayout({super.key, required this.child});

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
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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

    final positionState = useState(0.0);
    final opacity = 1 - positionState.value;

    final bottomNavHeight = 80.0 + MediaQuery.of(context).padding.bottom;
    final currentHeight = bottomNavHeight * (1 - positionState.value);

    final panel = context.isDesktopOrLandscape
        ? const PlayingDesktopScreen()
        : const PlayingScreenMobile();

    final router = GoRouter.of(context);

    final currentIndex =
        pages.contains(router.location) ? pages.indexOf(router.location) : null;
    onDestinationSelected(final index) {
      if (index >= pages.length && router.canPop()) {
        router.pop();
        return;
      }

      context.go(
        pages[index],
        // pageBuilder: fadeThroughTransitionBuilder,
        // transitionDuration: const Duration(milliseconds: 250),
      );
    }

    final delegate = ref.read(routerProvider);

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_filled),
        label: t.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.queue_music_outlined),
        label: t.music,
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
                controller: delegate.panelController,
                borderRadius: BorderRadius.circular(8),
                panel: panel,
                isDraggable: context.isMobileOrPortrait,
                collapsed: GestureDetector(
                  onTap: delegate.openPanel,
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
                onPanelOpened: () {
                  // push shadow route on open
                  if (router.location != '/player') {
                    router.push('/player');
                  }
                },
                onPanelClosed: () {
                  // pop shadow route on close
                  while (router.location == '/player') {
                    router.pop();
                  }
                },
              )
          ],
        );
      },
      child: child,
    );
    final root = AdaptiveLayout(
      transitionDuration: const Duration(milliseconds: 250),
      primaryNavigation: SlotLayout(config: <Breakpoint, SlotLayoutConfig>{
        Breakpoints.mediumAndUp: SlotLayout.from(
          key: const Key('Primary Navigation Medium'),
          builder: (context) => AdaptiveScaffold.standardNavigationRail(
            padding: EdgeInsets.zero,
            backgroundColor: context.colorScheme.surfaceContainer,
            leading: Padding(
              padding: EdgeInsets.only(
                top: Platform.isMacOS ? 24.0 : 0,
                bottom: 12.0,
              ),
              child: Consumer(builder: (context, ref, child) {
                final info = ref.watch(annivProvider.select((v) => v.info));

                return FloatingActionButton(
                  elevation: 2,
                  child: CircleAvatar(
                    child: Text(info!.user.nickname.substring(0, 1)),
                  ),
                  onPressed: () {},
                );
              }),
            ),
            labelType: NavigationRailLabelType.all,
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              ...destinations.map(
                (d) => NavigationRailDestination(
                  icon: d.icon,
                  label: Text(d.label),
                ),
              ),
              const NavigationRailDestination(
                icon: Icon(Icons.arrow_back),
                label: Text('back'),
                // disabled: !router.canPop(),
              )
            ],
          ),
        ),
      }),
      body: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Body Small'),
            builder: (context) => LayoutTopSafeArea(child: body),
          ),
          Breakpoints.mediumAndUp: SlotLayout.from(
            key: const Key('Body Medium'),
            builder: (context) => body,
          ),
        },
      ),
      bottomNavigation: SlotLayout(
        config: <Breakpoint, SlotLayoutConfig>{
          Breakpoints.small: SlotLayout.from(
            key: const Key('Bottom Navigation Small'),
            builder: (context) {
              final bar = standardBottomNavigationBar(
                currentIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: destinations,
              );
              return SizedBox(
                height: currentHeight,
                child: opacity == 1
                    ? bar
                    : AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: opacity,
                        child: bar,
                      ),
              );
            },
          ),
        },
      ),
    );
    return Material(child: root);
  }
}
