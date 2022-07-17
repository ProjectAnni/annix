import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomPlayer extends StatelessWidget {
  final double height;

  BottomPlayer({Key? key, this.height = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayerController player = Get.find();
    final AnnilController annil = Get.find();

    return GestureDetector(
      onTap: () {
        Get.toNamed('/playing');
      },
      child: Material(
        elevation: 16,
        child: Container(
          height: height,
          color: ElevationOverlay.colorWithOverlay(
              context.colorScheme.surface, context.colorScheme.primary, 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: height,
                width: height,
                padding: EdgeInsets.all(8.0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  child: Obx(() {
                    final item = player.playing;
                    if (item == null) {
                      return Container(
                        color: Colors.grey,
                      );
                    } else {
                      return annil.cover(albumId: item.albumId, tag: "playing");
                    }
                  }),
                ),
              ),
              Expanded(
                flex: 1,
                child: GetBuilder<PlayerController>(
                  builder: (player) => Marquee(
                    child: Text(player.playing?.track.title ?? ""),
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
