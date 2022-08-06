import 'package:annix/controllers/player_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/layout/layout.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/bottom_player/bottom_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixLayoutMobile extends AnnixLayout {
  static const pages = <String>[
    '/home',
    '/tags',
    '/server',
  ];

  static const INITIAL_MOBILE_PAGE = "/home";

  onDestinationSelected(int index) {
    AnnixBodyPageRouter.offNamed(pages[index]);
  }

  const AnnixLayoutMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnixBodyPageRouter router =
        Get.put(AnnixBodyPageRouter(INITIAL_MOBILE_PAGE));

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: WillPopScope(
              onWillPop: () async {
                final shouldCancel =
                    await Get.nestedKey(1)?.currentState?.maybePop();
                if (shouldCancel == null) {
                  // failed to pop
                  return true;
                } else {
                  return !shouldCancel;
                }
              },
              child: Navigator(
                key: Get.nestedKey(1),
                initialRoute: INITIAL_MOBILE_PAGE,
                onGenerateRoute: router.onGenerateRoute,
              ),
            ),
          ),
          GetBuilder<PlayerController>(
            builder: (player) => player.playing != null
                ? MobileBottomPlayer()
                : SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        return GetBuilder<PlayerController>(
          builder: (player) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: player.playing != null ? 56.0 : 0.0,
              ),
              child: FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  AnnixBodyPageRouter.toNamed("/search");
                },
                isExtended: true,
              ),
            );
          },
        );
      }),
      bottomNavigationBar: GetBuilder<AnnixBodyPageRouter>(
        builder: (router) {
          final route = router.currentPage;
          final selectedIndex =
              pages.indexOf(route) == -1 ? null : pages.indexOf(route);
          if (selectedIndex == null) {
            return SizedBox.shrink();
          }

          return NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
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
