import 'package:annix/controllers/player_controller.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/volume.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DesktopBottomPlayer extends StatelessWidget {
  final PlayerController player = Get.find();

  DesktopBottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnnixBodyPageRouter.offNamed('/playing');
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
                barHeight: 4.0,
                thumbRadius: 6,
                thumbGlowRadius: 12,
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
                    // left
                    Expanded(
                      child: Row(
                        children: [
                          // cover
                          Container(
                            padding: EdgeInsets.only(bottom: 8, top: 4),
                            child: PlayingMusicCover(card: true),
                          ),
                          // track info
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: GetBuilder<PlayerController>(
                                builder: (player) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.playing?.track.title ??
                                            "Not playing",
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .apply(
                                              fontSizeFactor: 1,
                                              fontWeightDelta: 2,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      ArtistText(
                                        player.playing?.track.artist ?? "",
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .apply(fontSizeFactor: 0.75),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // right
                    Row(
                      children: [
                        VolumeController(),
                        FavoriteButton(),
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
                        LoopModeButton(),
                        IconButton(
                          icon: Icon(Icons.queue_music_outlined),
                          onPressed: () {
                            AnnixBodyPageRouter.toNamed('/playing-queue');
                          },
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
}
