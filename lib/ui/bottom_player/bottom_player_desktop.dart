import 'package:annix/services/player.dart';
import 'package:annix/ui/widgets/playing_queue.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/volume.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopBottomPlayer extends StatelessWidget {
  const DesktopBottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AnnixRouterDelegate.of(context).off(name: '/playing');
      },
      child: SizedBox(
        height: 80,
        child: Column(
          children: [
            RepaintBoundary(
              child: Consumer<PlayerService>(
                builder: (context, player, child) {
                  return ChangeNotifierProvider.value(
                    value: player.playing,
                    child: Selector<PlayingTrack?, List<Duration>>(
                      selector: (_, playing) => [
                        playing?.position ?? Duration.zero,
                        playing?.duration ?? Duration.zero,
                      ],
                      builder: (context, durations, child) {
                        return ProgressBar(
                          progress: durations[0],
                          total: durations[1],
                          onSeek: (position) {
                            player.seek(position);
                          },
                          barHeight: 3.0,
                          thumbRadius: 6,
                          thumbGlowRadius: 12,
                          thumbCanPaintOutsideBar: false,
                          timeLabelLocation: TimeLabelLocation.none,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // left
                    Expanded(
                      child: Row(
                        children: [
                          // cover
                          Container(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
                            child: const PlayingMusicCover(animated: false),
                          ),
                          // track info
                          Expanded(
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
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
                        const VolumeController(),
                        const FavoriteButton(),
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 28,
                          onPressed: () =>
                              Provider.of<PlayerService>(context, listen: false)
                                  .previous(),
                        ),
                        const PlayPauseButton(
                          type: PlayPauseButtonType.elevated,
                          size: 56,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          iconSize: 28,
                          onPressed: () =>
                              Provider.of<PlayerService>(context, listen: false)
                                  .next(),
                        ),
                        const LoopModeButton(),
                        IconButton(
                          icon: const Icon(Icons.queue_music_outlined),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              useRootNavigator: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                              ),
                              builder: (context) {
                                return Container(
                                  alignment: Alignment.bottomRight,
                                  child: const PlayingQueue(),
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
