import 'package:annix/models/playlist.dart';
import 'package:annix/widgets/play_pause_button.dart';
import 'package:annix/widgets/repeat_button.dart';
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
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Alignment: left
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  width: 56,
                  height: 56,
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
                  Text('Artist', textScaleFactor: 0.8)
                ],
              )
            ],
          ),
          // Alignment: right
          Consumer<ActivePlaylist>(
            builder: (context, playlist, child) {
              return Row(
                children: [
                  RepeatButton(
                    initial: playlist.mode,
                    onRepeatModeChange: (mode) {
                      // TODO: do not listen here
                      playlist.setMode(mode);
                    },
                  ),
                  PlayPauseButton(),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
