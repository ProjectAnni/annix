import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback_service.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/volume.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DesktopBottomPlayer extends ConsumerWidget {
  /// Constant height of the player
  static const double height = 96;

  const DesktopBottomPlayer({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final player = ref.read(playbackProvider);
    final delegate = ref.read(routerProvider);

    return Container(
      color: ElevationOverlay.colorWithOverlay(
        context.colorScheme.surface,
        context.colorScheme.primary,
        0.5,
      ),
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _cover(player, delegate),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _trackInfoAndProgress(player),
            ),
          ),
          // right
          _playbackControl(player),
        ],
      ),
    );
  }

  Widget _cover(
      final PlaybackService player, final AnnixRouterDelegate router) {
    return GestureDetector(
      onTap: () {
        if (player.playing.source != null) {
          if (router.panelController.isPanelOpen) {
            router.panelController.close();
          } else {
            router.panelController.open();
          }
        }
      },
      child: const PlayingMusicCover(
        animated: false,
        card: false,
      ),
    );
  }

  Widget _trackInfoAndProgress(final PlaybackService player) {
    return Consumer(
      builder: (final context, final ref, final child) {
        final playing = ref.watch(playingProvider);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playing.source?.track.title ?? 'Not playing',
              style: context.textTheme.titleMedium?.apply(fontWeightDelta: 2),
              overflow: TextOverflow.ellipsis,
            ),
            ArtistText(
              playing.source?.track.artist ?? '',
              style: context.textTheme.labelSmall,
              search: true,
            ),
            const SizedBox(height: 8),
            RepaintBoundary(
              child: ProgressBar(
                progress: playing.position,
                total: playing.duration,
                onSeek: player.seek,
                barHeight: 3.0,
                thumbRadius: 6,
                thumbGlowRadius: 12,
                thumbCanPaintOutsideBar: false,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: context.textTheme.labelSmall,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _playbackControl(final PlaybackService player) {
    return Row(
      children: [
        const VolumeController(),
        const FavoriteButton(),
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: 28,
          onPressed: player.previous,
        ),
        const PlayPauseButton(
          type: PlayPauseButtonType.elevated,
          size: 56,
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: 28,
          onPressed: player.next,
        ),
        const LoopModeButton(),
      ],
    );
  }
}
