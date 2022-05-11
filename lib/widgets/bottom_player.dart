import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const double kPreviouNextMove = 150.0;

class BottomPlayer extends StatelessWidget {
  BottomPlayer({Key? key}) : super(key: key);

  final RxBool isSwitching = false.obs;

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    return GestureDetector(
      onTap: () {
        Get.toNamed('/playing');
      },
      onVerticalDragEnd: (details) async {
        if (isSwitching.value) {
          return;
        }

        final move = (details.primaryVelocity ?? 0);
        isSwitching.value = true;
        if (move > kPreviouNextMove) {
          await playing.previous();
        } else if (move < -kPreviouNextMove) {
          await playing.next();
        }
        isSwitching.value = false;
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
                      return annil.cover(
                        albumId: item.id.split('/')[0],
                        tag: "playing-cover",
                      );
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
              Obx(
                () => isSwitching.value
                    ? CircularProgressIndicator()
                    : PlayPauseButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
