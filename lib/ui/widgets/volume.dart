import 'package:annix/controllers/player_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VolumeController extends StatelessWidget {
  const VolumeController({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController player = Get.find();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Obx(() {
          return IconButton(
            icon: Icon(Icons.volume_up_outlined),
            selectedIcon: Icon(Icons.volume_off_outlined),
            isSelected: player.volume.value == 0,
            onPressed: () {
              player.setVolume(0);
            },
          );
        }),
        SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: Obx(
            () => ProgressBar(
              progress: Duration(seconds: (player.volume.value * 100).toInt()),
              total: Duration(seconds: 100),
              timeLabelLocation: TimeLabelLocation.none,
              thumbGlowRadius: 0,
              thumbRadius: 8,
              onDragUpdate: (position) {
                final volume = position.timeStamp.inSeconds;
                player.setVolume(volume.toDouble() / 100);
              },
              onSeek: (position) {
                final volume = position.inSeconds;
                player.setVolume(volume.toDouble() / 100);
              },
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }
}
