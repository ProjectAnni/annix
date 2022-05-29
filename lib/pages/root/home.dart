import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/widgets/buttons/theme_button.dart';
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
              InkWell(
                onTap: () => playing.fullShuffleMode(),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shuffle),
                      SizedBox(width: 8),
                      Text(
                        'Random songs',
                        style: context.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
