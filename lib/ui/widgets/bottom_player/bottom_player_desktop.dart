import 'package:annix/services/player.dart';
import 'package:annix/pages/playing/playing_queue.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/volume.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopBottomPlayer extends StatelessWidget {
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
            Consumer2<PlayingProgress, PlayerService>(
              builder: (context, progress, player, child) {
                return ProgressBar(
                  progress: progress.position,
                  total: progress.duration,
                  onSeek: (position) {
                    player.seek(position);
                  },
                  barHeight: 4.0,
                  thumbRadius: 6,
                  thumbGlowRadius: 12,
                  thumbCanPaintOutsideBar: false,
                  timeLabelLocation: TimeLabelLocation.none,
                );
              },
            ),
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
                            child: PlayingMusicCover(),
                          ),
                          // track info
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Consumer<PlayerService>(
                                builder: (context, player, child) {
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
                          onPressed: () =>
                              Provider.of<PlayerService>(context, listen: false)
                                  .previous(),
                        ),
                        PlayPauseButton(iconSize: 40),
                        IconButton(
                          icon: Icon(Icons.skip_next),
                          iconSize: 28,
                          onPressed: () =>
                              Provider.of<PlayerService>(context, listen: false)
                                  .next(),
                        ),
                        LoopModeButton(),
                        IconButton(
                          icon: Icon(Icons.queue_music_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.transparent,
                              builder: (context) {
                                return Container(
                                  alignment: Alignment.bottomRight,
                                  padding: EdgeInsets.only(bottom: 76),
                                  child: FractionallySizedBox(
                                    heightFactor: 0.4,
                                    widthFactor: 0.3,
                                    child: Material(
                                      child: Card(child: PlayingQueue()),
                                    ),
                                  ),
                                );
                              },
                            );
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
