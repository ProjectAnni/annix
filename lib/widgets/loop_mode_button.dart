import 'package:annix/controllers/playing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class LoopModeButton extends StatelessWidget {
  const LoopModeButton({Key? key}) : super(key: key);

  Icon getIcon(BuildContext context, PlayingController playing) {
    switch (playing.loopMode.value) {
      case LoopMode.off:
        return Icon(
          Icons.repeat,
          color: context.iconColor?.withOpacity(0.5),
        );
      case LoopMode.all:
        return Icon(Icons.repeat);
      case LoopMode.one:
        return Icon(Icons.repeat_one);
    }
  }

  LoopMode next(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();

    return Obx(
      () => IconButton(
        icon: getIcon(context, playing),
        onPressed: () {
          playing.setLoopMode(next(playing.loopMode.value));
        },
      ),
    );
  }
}
