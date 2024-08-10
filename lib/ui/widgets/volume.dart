import 'package:annix/providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class VolumeController extends ConsumerWidget {
  const VolumeController({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final volume = ref.watch(playbackProvider.select((final p) => p.volume));
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up_outlined),
          selectedIcon: const Icon(Icons.volume_off_outlined),
          isSelected: volume == 0,
          onPressed: () {
            final player = ref.read(playbackProvider);
            player.setVolume(0);
          },
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 100,
          child: ProgressBar(
            progress: Duration(seconds: (volume * 100).toInt()),
            total: const Duration(seconds: 100),
            timeLabelLocation: TimeLabelLocation.none,
            barHeight: 4,
            thumbGlowRadius: 0,
            thumbRadius: 8,
            onDragUpdate: (final position) {
              final volume = position.timeStamp.inSeconds;
              final player = ref.read(playbackProvider);
              player.setVolume(volume.toDouble() / 100);
            },
            onSeek: (final position) {
              final volume = position.inSeconds;
              final player = ref.read(playbackProvider);
              player.setVolume(volume.toDouble() / 100);
            },
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
