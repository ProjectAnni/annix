import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MaterialYouPlayerPage extends ConsumerWidget {
  const MaterialYouPlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(playingProvider);
    final playback = ref.watch(playbackProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    // Check if a track is currently loaded
    final hasTrack = playing.source?.track != null;

    return Scaffold(
      body: SafeArea(
        child: hasTrack
            ? _buildPlayerContent(
                context, ref, playing, playback, colorScheme, size)
            : _buildEmptyState(context, colorScheme),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No track playing',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a track to start playing',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerContent(
    BuildContext context,
    WidgetRef ref,
    PlayingTrack playing,
    PlaybackService playback,
    ColorScheme colorScheme,
    Size size,
  ) {
    final track = playing.source!.track!;
    final albumTitle = track.albumTitle ?? '';
    final artistName = track.artist ?? 'Unknown Artist';
    final trackTitle = track.title ?? 'Unknown Track';

    return Column(
      children: [
        // App bar with back button and menu
        Expanded(
          flex: 1,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'Now Playing',
                  style: context.textTheme.titleMedium,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    // Handle menu options
                    if (value == 'sleep_timer') {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            _buildSleepTimerSheet(context, ref),
                      );
                    } else if (value == 'endless_mode') {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            _buildEndlessModeSheet(context, ref),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'sleep_timer',
                      child: Row(
                        children: [
                          Icon(Icons.bedtime_outlined),
                          SizedBox(width: 8),
                          Text('Sleep Timer'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'endless_mode',
                      child: Row(
                        children: [
                          Icon(Icons.repeat),
                          SizedBox(width: 8),
                          Text('Endless Mode'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'equalizer',
                      child: Row(
                        children: [
                          Icon(Icons.equalizer),
                          SizedBox(width: 8),
                          Text('Equalizer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Album art
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            children: [
              Expanded(
                flex: 8,
                child: PlayingMusicCover(
                  card: true,
                  borderRadius: BorderRadius.circular(16),
                  animated: true,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),

        // Track info
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Track title and favorite button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackTitle,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            artistName,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (albumTitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              albumTitle,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const FavoriteButton(),
                  ],
                ),

                // Progress bar
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ProgressBar(
                        progress: playing.position,
                        total: playing.duration == Duration.zero
                            ? playing.position
                            : playing.duration,
                        onSeek: (duration) {
                          playback.seek(duration);
                        },
                        barHeight: 4,
                        thumbRadius: 8,
                        thumbGlowRadius: 16,
                        thumbColor: colorScheme.primary,
                        progressBarColor: colorScheme.primary,
                        baseBarColor: colorScheme.surfaceVariant,
                        timeLabelTextStyle:
                            context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoopModeButton(),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 36,
                      onPressed: () {
                        playback.previous();
                      },
                    ),
                    PlayPauseButton.large(),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 36,
                      onPressed: () {
                        playback.next();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.shuffle),
                      color: playback.shuffleMode == ShuffleMode.on
                          ? colorScheme.primary
                          : null,
                      onPressed: () {
                        playback.shuffleMode = playback.shuffleMode.next();
                        playback.notifyListeners();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Expanded(
          flex: 1,
          child: Container(),
        ),
      ],
    );
  }

  // Helper methods for bottom sheets
  Widget _buildSleepTimerSheet(BuildContext context, WidgetRef ref) {
    final sleepTimer = ref.watch(sleepTimerProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sleep Timer',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Sleep timer options would go here
          Text('Sleep timer implementation would go here'),
        ],
      ),
    );
  }

  Widget _buildEndlessModeSheet(BuildContext context, WidgetRef ref) {
    final endlessMode = ref.watch(endlessModeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Endless Mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Endless mode options would go here
          Text('Endless mode implementation would go here'),
        ],
      ),
    );
  }
}
