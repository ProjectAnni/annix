import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/pages/playlist_detail.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/widgets/buttons/theme_button.dart';
import 'package:annix/widgets/icon_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayingController playing = Get.find();

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
            crossAxisCount: 2,
            childAspectRatio: 4 * 0.618,
            crossAxisSpacing: 4,
            children: [
              // Random mode
              IconCard(
                icon: Icon(Icons.shuffle),
                child: Text(
                  'Random songs',
                  style: context.textTheme.titleSmall,
                ),
                onTap: () => playing.fullShuffleMode(),
              ),
              // My favorite
              IconCard(
                icon: Icon(Icons.favorite_outlined),
                child: Text(
                  'My favorite',
                  style: context.textTheme.titleSmall,
                ),
                onTap: () => Get.to(() => FavoriteDetail()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
