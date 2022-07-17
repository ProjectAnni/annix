import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/desktop/main_desktop.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopBottomPlayer extends StatelessWidget {
  final PlayerController player = Get.find();

  DesktopBottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnilController annil = Get.find();

    return GestureDetector(
      onTap: () {
        MainDesktopScreenController.to.changePage(0);
      },
      child: Container(
        height: 80,
        child: Column(
          children: [
            Obx(() {
              return ProgressBar(
                progress: player.progress.value,
                total: player.duration.value,
                onSeek: (position) {
                  player.seek(position);
                },
                barHeight: 2.0,
                thumbRadius: 4,
                thumbGlowRadius: 10,
                thumbCanPaintOutsideBar: false,
                timeLabelLocation: TimeLabelLocation.none,
              );
            }),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // cover
                    Container(
                      padding: EdgeInsets.only(bottom: 8, top: 4),
                      child: _card(
                        child: GetBuilder<PlayerController>(
                          builder: (player) {
                            return annil.cover(
                              albumId: player.playing?.albumId,
                              tag: "playing",
                            );
                          },
                        ),
                      ),
                    ),
                    // track info
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 300),
                        child: GetBuilder<PlayerController>(
                          builder: (player) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Marquee(
                                  child: Text(
                                    player.playing?.track.title ??
                                        "Not playing",
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                          fontSizeFactor: 1,
                                          fontWeightDelta: 2,
                                        ),
                                  ),
                                ),
                                Marquee(
                                  child: Text(
                                    player.playing?.track.artist ?? "No artist",
                                    style: DefaultTextStyle.of(context)
                                        .style
                                        .apply(
                                          fontSizeFactor: 0.75,
                                        ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    FavoriteButton(),
                    Expanded(child: Container()),
                    LoopModeButton(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.skip_previous),
                          iconSize: 28,
                          onPressed: () => player.previous(),
                        ),
                        PlayPauseButton(iconSize: 40),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          iconSize: 28,
                          onPressed: () => player.next(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 4,
      margin: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: 1,
        child: child,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
