import 'package:annix/controllers/player_controller.dart';
import 'package:audioplayers/audioplayers.dart';
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
      child: Obx(
        () => Material(
          type: MaterialType.transparency,
          child: IconButton(
            icon: Icon(
              playing.playerState.value == PlayerState.playing
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            iconSize: iconSize,
            onPressed: () => playing.playOrPause(),
          ),
        ),
      ),
    );
  }
}
