import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kPreviouNextMove = 150.0;

class BottomPlayer extends StatelessWidget {
  BottomPlayer({Key? key}) : super(key: key);

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
              context.colorScheme.surface, context.colorScheme.primary, 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 60,
                width: 60,
                padding: EdgeInsets.all(8.0),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  elevation: 4,
                  margin: EdgeInsets.zero,
                  child: Obx(() {
                    final item = playing.currentPlaying.value;
                    if (item == null) {
                      return Container(
                        color: Colors.grey,
                      );
                    } else {
                      return annil.cover(albumId: item.id.split('/')[0]);
                    }
                  }),
                ),
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
