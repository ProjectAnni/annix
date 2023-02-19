import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/volume.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopBottomPlayer extends StatelessWidget {
  const DesktopBottomPlayer({super.key, required this.onClick});

  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final player = context.read<PlaybackService>();
        if (player.playing != null) {
          onClick();
        }
      },
      child: Container(
        color: ElevationOverlay.colorWithOverlay(
          context.colorScheme.surface,
          context.colorScheme.primary,
          0.5,
        ),
        height: 96,
        child: Column(
          children: [
            // const Divider(height: 1),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // left
                  Expanded(
                    child: Row(
                      children: [
                        // cover
                        const PlayingMusicCover(
                          animated: false,
                          card: false,
                        ),
                        // track info
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Consumer<PlaybackService>(
                              builder: (context, player, child) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.playing?.track.title ??
                                          'Not playing',
                                      style: context.textTheme.titleMedium
                                          ?.apply(fontWeightDelta: 2),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    ArtistText(
                                      player.playing?.track.artist ?? '',
                                      style: context.textTheme.labelSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    RepaintBoundary(
                                      child: Consumer<PlaybackService>(
                                        builder: (context, player, child) {
                                          return ChangeNotifierProvider.value(
                                            value: player.playing,
                                            child: Selector<PlayingTrack?,
                                                List<Duration>>(
                                              selector: (_, playing) => [
                                                playing?.position ??
                                                    Duration.zero,
                                                playing?.duration ??
                                                    Duration.zero,
                                              ],
                                              builder:
                                                  (context, durations, child) {
                                                return ProgressBar(
                                                  progress: durations[0],
                                                  total: durations[1],
                                                  onSeek: (position) {
                                                    player.seek(position);
                                                  },
                                                  barHeight: 3.0,
                                                  thumbRadius: 6,
                                                  thumbGlowRadius: 12,
                                                  thumbCanPaintOutsideBar:
                                                      false,
                                                  timeLabelLocation:
                                                      TimeLabelLocation.sides,
                                                  timeLabelTextStyle: context
                                                      .textTheme.labelSmall,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      ),
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
                      // const VolumeController(),
                      const FavoriteButton(),
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 28,
                        onPressed: () =>
                            context.read<PlaybackService>().previous(),
                      ),
                      const PlayPauseButton(
                        type: PlayPauseButtonType.elevated,
                        size: 56,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 28,
                        onPressed: () => context.read<PlaybackService>().next(),
                      ),
                      const LoopModeButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
