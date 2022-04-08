import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/widgets/player_buttons.dart';
import 'package:annix/widgets/third_party/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    return GestureDetector(
      onTap: () {
        Get.toNamed('/playing');
      },
      child: Material(
        elevation: 16,
        child: Container(
          height: 60,
          color: ElevationOverlay.colorWithOverlay(
              context.theme.colorScheme.surface,
              context.theme.colorScheme.primary,
              3.0),
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Card(
                elevation: 4,
                margin: EdgeInsets.zero,
                child: Obx(() {
                  final item = playing.currentPlaying.value;
                  if (item == null) {
                    return Container(
                      color: Colors.grey,
                      height: 60,
                      width: 60,
                    );
                  } else {
                    return Hero(
                      tag: "playing-cover",
                      child: annil.cover(albumId: item.id.split('/')[0]),
                    );
                  }
                }),
              ),
              Expanded(
                flex: 1,
                child: Obx(
                  () => Marquee(
                    child: Text(playing.currentPlaying.value?.title ?? ""),
                  ),
                ),
              ),
              PlayPauseButton(),
            ],
          ),
        ),
      ),
    );
  }
}
