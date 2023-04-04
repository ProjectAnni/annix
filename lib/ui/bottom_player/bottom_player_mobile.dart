import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MobileBottomPlayer extends StatelessWidget {
  final double height;

  const MobileBottomPlayer({super.key, this.height = 60});

  @override
  Widget build(final BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: ElevationOverlay.colorWithOverlay(
          context.colorScheme.surface,
          context.colorScheme.primary,
          3.0,
        ),
      ),
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const PlayingMusicCover(card: true, animated: false),
          ),
          Expanded(
            flex: 1,
            child: Consumer(
              builder: (final context, final ref, final child) {
                final playing = ref.watch(playingProvider);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playing?.track.title ?? '',
                      style: context.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: ref
                          .read(settingsProvider)
                          .mobileShowArtistInBottomPlayer,
                      builder: (final context, final showArtist, final _) {
                        if (showArtist) {
                          return ArtistText(
                            playing?.track.artist ?? '',
                            style: context.textTheme.bodySmall,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer(
              builder: (final context, final ref, final child) {
                final double? progress =
                    ref.watch(playingProvider.select((final playing) {
                  if (playing == null) {
                    return null;
                  }

                  if (playing.duration == Duration.zero) {
                    return 0;
                  }

                  return playing.position.inMicroseconds /
                      playing.duration.inMicroseconds;
                }));
                if (progress == null) {
                  return child!;
                }

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(value: progress),
                    child!,
                  ],
                );
              },
              child: PlayPauseButton.small(),
            ),
          ),
        ],
      ),
    );
  }
}
