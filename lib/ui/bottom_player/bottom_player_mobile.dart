import 'package:annix/global.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileBottomPlayer extends StatelessWidget {
  final double height;

  const MobileBottomPlayer({Key? key, this.height = 60}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              builder: (context, player, child) => Column(
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
                    builder: (context, showArtist, _) {
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
              selector: (context, player) {
                return player.playing;
              },
              builder: (context, playing, child) {
                if (playing == null) {
                  return child!;
                }

                return ChangeNotifierProvider.value(
                  value: playing,
                  child: Selector<PlayingTrack, double>(
                    selector: (context, playing) {
                      return playing.position.inMicroseconds /
                          playing.duration.inMicroseconds;
                    },
                    builder: (context, progress, child) {
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
