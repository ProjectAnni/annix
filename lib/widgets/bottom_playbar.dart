import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/play_pause_button.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';

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
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          // TODO: cover
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.white),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Music Title'),
                          Text('Artist', textScaleFactor: 0.8),
                        ],
                      ),
                    ],
                  ),
                  PlayPauseButton(),
                  Row(
                    children: [
                      Text("TODO"),
                      // RepeatButton(
                      //   initial: playlist.mode,
                      //   onRepeatModeChange: (mode) {
                      //     // TODO: do not listen here
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
