import 'package:annix/controllers/playing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayPauseButton extends StatelessWidget {
  final double? iconSize;

  const PlayPauseButton({Key? key, this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();

    return Hero(
      tag: "play-pause-button",
      child: Obx(
        () => Material(
          type: MaterialType.transparency,
          child: IconButton(
            icon: Icon(
              playing.isPlaying.value ? Icons.pause : Icons.play_arrow,
            ),
            iconSize: iconSize,
            onPressed: () => playing.playOrPause(),
          ),
        ),
      ),
    );
  }
}
