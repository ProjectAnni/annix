import 'package:annix/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoopModeButton extends StatelessWidget {
  const LoopModeButton({Key? key}) : super(key: key);

  Icon getIcon(BuildContext context, PlayerController playing) {
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
      case LoopMode.random:
        return Icon(Icons.shuffle);
    }
  }

  LoopMode next(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.random;
      case LoopMode.random:
        return LoopMode.off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playing = Get.find();

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
