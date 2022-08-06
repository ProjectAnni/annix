import 'package:annix/controllers/player_controller.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
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
                    // left
                    Expanded(
                      child: Row(
                        children: [
                          // cover
                          Container(
                            padding: EdgeInsets.only(bottom: 8, top: 4),
                            child: _card(child: PlayingMusicCover()),
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
