import 'package:annix/controllers/playing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    return Obx(
      () => IconButton(
        icon: Icon(
          Icons.shuffle,
          color: playing.shuffleEnabled.value
              ? null
              : context.iconColor?.withOpacity(0.5),
        ),
        onPressed: () {
          playing.setShuffleModeEnabled(!playing.shuffleEnabled.value);
        },
      ),
    );
  }
}
