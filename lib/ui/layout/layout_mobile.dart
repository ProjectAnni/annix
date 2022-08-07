import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/bottom_player/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AnnixLayoutMobile extends AnnixLayout {
  final Widget child;

  static const pages = <String>[
    '/home',
    '/tags',
    '/server',
  ];

  const AnnixLayoutMobile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          Consumer<PlayerService>(
            builder: (context, player, child) => player.playing != null
                ? MobileBottomPlayer()
                : SizedBox.shrink(),
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
              child: Icon(Icons.search),
              onPressed: () {
                AnnixRouterDelegate.of(context).to(name: "/search");
              },
              isExtended: true,
            ),
          );
        },
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final delegate = AnnixRouterDelegate.of(context);
          final route = delegate.currentRoute;
          final selectedIndex =
              pages.indexOf(route) == -1 ? null : pages.indexOf(route);
          if (selectedIndex == null) {
            return SizedBox.shrink();
          }

          return NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              delegate.off(name: pages[index]);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.casino_outlined),
                label: I18n.HOME.tr,
              ),
              NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                label: I18n.CATEGORY.tr,
              ),
              NavigationDestination(
                icon: Icon(Icons.dns_outlined),
                label: I18n.SERVER.tr,
              ),
            ],
          );
        },
      ),
    );
  }
}
