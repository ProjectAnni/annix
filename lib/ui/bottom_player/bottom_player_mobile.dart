import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/swiper.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MobileBottomPlayer extends ConsumerWidget {
  /// Height of the mobile player
  static const double height = 64;

  const MobileBottomPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.shadow
                .withValues(alpha: context.isDarkMode ? 0.4 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RepaintBoundary(
              child: Consumer(builder: (context, ref, child) {
                final playing = ref.watch(playingProvider);
                return ProgressBar(
                  progress: playing.position,
                  total: playing.duration == Duration.zero
                      ? playing.position
                      : playing.duration,
                  timeLabelLocation: TimeLabelLocation.none,
                  thumbCanPaintOutsideBar: false,
                  thumbRadius: 0,
                  barHeight: 2,
                  progressBarColor: context.colorScheme.primary,
                  baseBarColor: context.colorScheme.surfaceContainerHighest,
                );
              }),
            ),
          ),

          // Player controls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  // Album art with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: PlayingMusicCover(card: false, animated: false),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(child: PlayingTrackSwiper()),

                  // Control buttons
                  const FavoriteButton(),

                  PlayPauseButton.small(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
