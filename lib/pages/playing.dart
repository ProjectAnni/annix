import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/widgets/player_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingScreen extends StatelessWidget {
  const PlayingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    var inner = Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 16,
              child: Hero(
                tag: "playing-cover",
                child: Obx(() {
                  final item = playing.currentPlaying.value;
                  if (item == null) {
                    return Container();
                  } else {
                    return annil.cover(albumId: item.id.split('/')[0]);
                  }
                }),
              ),
            ),
          ),
          Obx(
            () => Text(
              playing.currentPlaying.value?.title ?? "",
              style: context.textTheme.titleLarge,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                iconSize: 48,
                onPressed: () => playing.previous(),
              ),
              PlayPauseButton(iconSize: 48),
              IconButton(
                icon: Icon(Icons.skip_next),
                iconSize: 48,
                onPressed: () => playing.next(),
              ),
            ],
          ),
        ],
      ),
    );

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 300) {
          Get.back();
        }
      },
      child: inner,
    );
  }
}
