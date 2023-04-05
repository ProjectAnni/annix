import 'package:annix/providers.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/playing/playing_desktop.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/bottom_player/bottom_player.dart';
import 'package:annix/utils/anni_weslide_controller.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:we_slide/we_slide.dart';

class AnnixLayoutDesktop extends ConsumerStatefulWidget {
  final AnnixRouterDelegate router;
  final Widget child;

  const AnnixLayoutDesktop({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  ConsumerState<AnnixLayoutDesktop> createState() => _AnnixLayoutDesktopState();
}

class _AnnixLayoutDesktopState extends ConsumerState<AnnixLayoutDesktop> {
  static final slideController = AnniWeSlideController(initial: false);

  static const pages = <String>[
    '/home',
    '/tags',
    '/settings',
  ];

  @override
  Widget build(final BuildContext context) {
    final double panelMaxSize = MediaQuery.of(context).size.height;

    final body = Expanded(
      child: Row(
        children: <Widget>[
          (() {
            final route = widget.router.currentRoute;
            final selectedIndex =
                pages.contains(route) ? pages.indexOf(route) : null;

            return NavigationRail(
              // minExtendedWidth: 192,
              selectedIndex: selectedIndex,
              onDestinationSelected: (final index) {
                widget.router.off(name: pages[index]);
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
          // const VerticalDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );

    final slide = Consumer(builder: (final context, final ref, final child) {
      final isPlaying =
          ref.watch(playbackProvider.select((final p) => p.playing != null));

      return WeSlide(
        controller: slideController,
        hideAppBar: false,
        hideFooter: false,
        parallax: true,
        panelBorderRadiusBegin: 12,
        panelBorderRadiusEnd: 0,
        backgroundColor: Colors.transparent,
        appBarHeight: 60,
        appBar: Material(
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Center(child: FlutterLogo()),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.router.popRoute();
                },
              ),
              const Spacer(),
              const SizedBox(
                width: 360,
                child: HomeAppBar(
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        body: Material(child: body),
        panelMinSize: 80,
        panelMaxSize: panelMaxSize,
        isUpSlide: false,
        panelHeader: GestureDetector(
          onTap: () {
            if (isPlaying) {
              slideController.show();
            }
          },
          child: const MobileBottomPlayer(),
        ),
        panel: PlayingDesktopScreen(onBack: slideController.hide),
        footerHeight: 96,
        footer: DesktopBottomPlayer(onClick: () => slideController.show()),
      );
    });

    final root = Scaffold(body: slide);
    return root;

    // return Navigator(
    //   pages: [MaterialPage(child: root)],
    //   onPopPage: (final route, final result) {
    //     return false;
    //   },
    //   observers: [ThemePopObserver(ref.read(themeProvider))],
    // );
  }
}
