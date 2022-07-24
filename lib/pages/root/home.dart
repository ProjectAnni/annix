import 'package:annix/controllers/player_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/services/global.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/widgets/buttons/theme_button.dart';
import 'package:annix/widgets/icon_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayerController player = Get.find();

    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(
            title: Text("Annix"),
            actions: [ThemeButton()],
          ),
        ];
      },
      body: CustomScrollView(
        slivers: [
          SliverGrid.count(
            crossAxisCount: Global.isDesktop ? 4 : 2,
            childAspectRatio: Global.isDesktop ? 1 : 4 * 0.618,
            children: [
              // Random mode
              IconCard(
                icon: Icon(Icons.shuffle),
                child: Text(
                  I18n.SHUFFLE_MODE.tr,
                  style: context.textTheme.titleSmall,
                ),
                onTap: () => player.fullShuffleMode(),
              ),
              // My favorite
              IconCard(
                icon: Icon(Icons.favorite_outlined),
                child: Text(
                  I18n.MY_FAVORITE.tr,
                  style: context.textTheme.titleSmall,
                ),
                onTap: () => AnnixBodyPageRouter.toNamed("/favorite"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
