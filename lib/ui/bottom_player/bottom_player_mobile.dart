import 'package:annix/global.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

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
            child: Consumer<PlaybackService>(
              builder: (final context, final player, final child) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.playing?.track.title ?? '',
                    style: context.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable:
                        Global.settings.mobileShowArtistInBottomPlayer,
                    builder: (final context, final showArtist, final _) {
                      if (showArtist) {
                        return ArtistText(
                          player.playing?.track.artist ?? '',
                          style: context.textTheme.bodySmall,
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Selector<PlaybackService, PlayingTrack?>(
              selector: (final context, final player) {
                return player.playing;
              },
              builder: (final context, final playing, final child) {
                if (playing == null) {
                  return child!;
                }

                return ChangeNotifierProvider.value(
                  value: playing,
                  child: Selector<PlayingTrack, double>(
                    selector: (final context, final playing) {
                      if (playing.duration == Duration.zero) {
                        return 0;
                      }

                      return playing.position.inMicroseconds /
                          playing.duration.inMicroseconds;
                    },
                    builder: (final context, final progress, final child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(value: progress),
                          child!,
                        ],
                      );
                    },
                    child: child,
                  ),
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
