import 'package:annix/services/global.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/material.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;

  PlayPauseButton({this.size = 32});

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return SquareIconButton(
      child: Icon(
          Global.audioService.isPlaying
              ? Icons.pause_rounded
              : Icons.play_arrow_rounded,
          size: widget.size),
      onPressed: () async {
        setState(() {
          if (Global.audioService.isPlaying) {
            Global.audioService.player.pause();
          } else {
            Global.audioService.player.play();
          }
        });
      },
    );
  }
}
