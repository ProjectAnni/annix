import 'dart:typed_data';

import 'package:annix/metadata/metadata.dart';
import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/play_pause_button.dart';
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
      height: 80,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Material(
              elevation: 8.0,
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      FractionallySizedBox(
                        heightFactor: 0.9,
                        child: CurrentMusicCover(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: CurrentMusicInfo(),
                      ),
                    ],
                  ),
                  PlayPauseButton(),
                  Row(
                    children: [
                      Text("TODO"),
                      // TODO: implement repeat button
                      // RepeatButton(
                      //   initial: playlist.mode,
                      //   onRepeatModeChange: (mode) {
                      //     playlist.setMode(mode);
                      //   },
                      // ),
                    ],
                  )
                ],
              ),
            ),
          ),
          ValueListenableBuilder<AnniPositionState>(
            valueListenable: Global.audioService.positionNotifier,
            builder: (context, value, child) {
              var theme = Theme.of(context);
              print({value.buffered, value.progress, value.total});
              return ProgressBar(
                progress: value.progress,
                buffered: value.buffered,
                total: value.total ?? Duration.zero,

                // not played color
                baseBarColor: theme.colorScheme.background,
                // played color
                progressBarColor: theme.colorScheme.primary,
                // hide time played
                timeLabelLocation: TimeLabelLocation.none,
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
          ),
        ],
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
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(snapshot.data?.title ?? "Unknown Title"),
                        Text(
                          snapshot.data?.artist ?? "Unknown Artist",
                          textScaleFactor: 0.8,
                        ),
                      ],
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
    return Consumer<AnnilPlaylist>(
      builder: (context, value, child) {
        if (value.playing == null) {
          // not playing, return empty cover
          return DecoratedBox(
            decoration: BoxDecoration(color: Colors.white),
          );
        } else {
          // playing, get cover by catalog
          return FutureBuilder<Uint8List>(
            future: Global.annil.getCover(catalog: value.playingCatalog!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!);
              } else {
                return DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                );
              }
            },
          );
        }
      },
    );
  }
}
