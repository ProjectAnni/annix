import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/playing/playing_mobile.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileBottomPlayer extends StatelessWidget {
  final double height;

  MobileBottomPlayer({Key? key, this.height = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // use Get.to to use root navigator
        Get.to(() => PlayingMobileScreen());
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
                child: PlayingMusicCover(),
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
