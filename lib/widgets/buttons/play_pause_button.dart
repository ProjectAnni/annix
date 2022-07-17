import 'package:annix/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayPauseButton extends StatelessWidget {
  final double? iconSize;

  const PlayPauseButton({Key? key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController playing = Get.find();

    return Hero(
      tag: "play-pause-button",
      child: Material(
        type: MaterialType.transparency,
        child: Obx(() {
          final status = playing.playerStatus.value;
          if (status == PlayerStatus.buffering) {
            return CircularProgressIndicator(strokeWidth: 2);
          } else {
            return IconButton(
              isSelected: status == PlayerStatus.playing,
              selectedIcon: Icon(Icons.pause),
              icon: Icon(Icons.play_arrow),
              iconSize: iconSize,
              onPressed: () => playing.playOrPause(),
            );
          }
        }),
      ),
    );
  }
}
