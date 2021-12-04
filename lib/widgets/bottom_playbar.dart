import 'dart:typed_data';

import 'package:annix/metadata/metadata.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/play_pause_button.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomPlayBar extends StatefulWidget {
  @override
  _BottomPlayBarState createState() => _BottomPlayBarState();
}

class _BottomPlayBarState extends State<BottomPlayBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Material(
        elevation: 8.0,
        color: Theme.of(context).primaryColor.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AspectRatio(
                  aspectRatio: 1.4,
                  child: Expanded(
                    child: Container(),
                  ),
                ),
                FractionallySizedBox(
                  heightFactor: 0.9,
                  child: CurrentMusicCover(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: CurrentMusicInfo(),
                ),
                AspectRatio(
                  aspectRatio: 0.2,
                  child: Expanded(
                    child: Container(),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 600,
              child: Consumer<AnnilPlaylist>(
                builder: (context, playlist, child) {
                  return ValueListenableBuilder<AnniPositionState>(
                    valueListenable: Global.audioService.positionNotifier,
                    builder: (context, value, child) {
                      var theme = Theme.of(context);
                      var total = value.total;
                      if (total == null || total == Duration.zero) {
                        total = Global.durations[
                                '${playlist.playingCatalog}/${playlist.playingTrackId}'] ??
                            Duration.zero;
                      }
                      print([value.progress, total]);
                      return ProgressBar(
                        progress: value.progress,
                        buffered: value.buffered,
                        total: total,

                        // not played color
                        baseBarColor: theme.colorScheme.background,
                        // played color
                        progressBarColor: theme.colorScheme.primary,
                        // hide time played
                        timeLabelLocation: TimeLabelLocation.sides,
                        barHeight: 2.0,
                        thumbRadius: 6,
                        thumbGlowRadius: 12,
                        thumbColor: theme.colorScheme.secondary,
                        thumbCanPaintOutsideBar: false,
                        onSeek: (duration) {
                          Global.audioService.player.seek(duration);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            PlayController(),
          ],
        ),
      ),
    );
  }
}

class CurrentMusicInfo extends StatelessWidget {
  const CurrentMusicInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnilPlaylist>(
      builder: (context, value, child) {
        return value.playing != null
            ? FutureBuilder<Track?>(
                future: Global.metadataSource.getTrack(
                  catalog: value.playingCatalog!,
                  trackIndex: value.playingTrackIndex!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Container(
                      constraints: BoxConstraints(maxWidth: 300),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data?.title ?? "Unknown Title",
                            textScaleFactor: 1.2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            snapshot.data?.artist ?? "Unknown Artist",
                            textScaleFactor: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              )
            : Container();
      },
    );
  }
}

class CurrentMusicCover extends StatelessWidget {
  const CurrentMusicCover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Consumer<AnnilPlaylist>(
        builder: (context, value, child) {
          if (value.playing == null) {
            // not playing, return empty cover
            return Container();
          } else {
            // playing, get cover by catalog
            return FutureBuilder<Uint8List>(
              future: Global.annil.getCover(catalog: value.playingCatalog!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.scaleDown,
                    filterQuality: FilterQuality.medium,
                  );
                } else {
                  return Container();
                }
              },
            );
          }
        },
      ),
    );
  }
}

class PlayController extends StatelessWidget {
  const PlayController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FractionallySizedBox(
          heightFactor: 0.6,
          child: RepeatButton(
            initial: Global.audioService.repeatMode,
            onRepeatModeChange: (mode) {
              Global.audioService.repeatMode = mode;
            },
          ),
        ),
        FractionallySizedBox(
          heightFactor: 0.6,
          child: SquareIconButton(
            child: Icon(Icons.skip_previous),
            onPressed: () {
              Global.audioService.player.seekToPrevious();
            },
          ),
        ),
        FractionallySizedBox(
          heightFactor: 0.8,
          child: PlayPauseButton(),
        ),
        FractionallySizedBox(
          heightFactor: 0.6,
          child: SquareIconButton(
            child: Icon(Icons.skip_next),
            onPressed: () {
              Global.audioService.player.seekToNext();
            },
          ),
        ),
        AspectRatio(
          aspectRatio: 0.5,
          child: Expanded(
            child: Container(),
          ),
        ),
      ],
    );
  }
}
