import 'dart:typed_data';

import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/play_pause_button.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

class BottomPlayBarDesktop extends StatefulWidget {
  @override
  _BottomPlayBarDesktopState createState() => _BottomPlayBarDesktopState();
}

class _BottomPlayBarDesktopState extends State<BottomPlayBarDesktop> {
  Widget _currentMusicInfo() {
    return Consumer<AnnilPlaylist>(
      builder: (context, playlist, child) {
        if (playlist.playing == null) {
          return Container();
        }

        MediaItem item = playlist.playing!.tag;
        return Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                textScaleFactor: 1.2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.artist ?? "Unknown Artist",
                textScaleFactor: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

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
                  child: _currentMusicInfo(),
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
              width: 550,
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
                        timeLabelLocation: TimeLabelLocation.below,
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
            DesktopPlayController(),
          ],
        ),
      ),
    );
  }
}

class BottomPlayerMobile extends StatefulWidget {
  const BottomPlayerMobile({Key? key}) : super(key: key);

  @override
  _BottomPlayerMobileState createState() => _BottomPlayerMobileState();
}

class _BottomPlayerMobileState extends State<BottomPlayerMobile> {
  Widget _currentMusicInfo() {
    return Consumer<AnnilPlaylist>(
      builder: (context, playlist, child) {
        if (playlist.playing == null) {
          return Container();
        }

        MediaItem item = playlist.playing!.tag;
        return Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: Text(
            item.title,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Material(
        elevation: 8.0,
        color: Theme.of(context).primaryColor.withOpacity(0.8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FractionallySizedBox(
                  heightFactor: 0.9,
                  child: CurrentMusicCover(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: _currentMusicInfo(),
                ),
              ],
            ),
            FractionallySizedBox(
              heightFactor: 0.8,
              child: PlayPauseButton(),
            ),
          ],
        ),
      ),
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

class DesktopPlayController extends StatelessWidget {
  const DesktopPlayController({Key? key}) : super(key: key);

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
        FractionallySizedBox(
          heightFactor: 0.6,
          child: SquareIconButton(
            child: false /* TODO: expanded */ ? Icon(Icons.expand_more)
                : Icon(Icons.expand_less),
            onPressed: () {
              // TODO: Change route
            },
          ),
        ),
      ],
    );
  }
}
