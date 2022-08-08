import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/bottom_player/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          Consumer<PlayerService>(
            builder: (context, player, child) {
              if (player.playing != null && router.currentRoute != "/playing") {
                return const MobileBottomPlayer();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return Consumer<PlayerService>(
            builder: (context, player, child) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: player.playing != null ? 48.0 : 0.0,
                ),
                child: child,
              );
            },
            child: FloatingActionButton(
              onPressed: () {
                router.to(name: "/search");
              },
              isExtended: true,
              child: const Icon(Icons.search),
            ),
          );
        },
      ),
      bottomNavigationBar: (() {
        final route = router.currentRoute;
        final selectedIndex =
            pages.contains(route) ? pages.indexOf(route) : null;
        if (selectedIndex == null) {
          return const SizedBox.shrink();
        }

        return NavigationBar(
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
        );
      })(),
    );
  }
}
