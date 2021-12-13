import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;

  PlayPauseButton({this.size = 32});

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnnilPlayState>(
      builder: (context, value, child) {
        return SquareIconButton(
          child: Icon(
            value.state.playing
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: widget.size,
          ),
          onPressed: () async {
            if (value.state.playing) {
              Global.audioService.player.pause();
            } else {
              Global.audioService.play();
            }
          },
        );
      },
    );
  }
}
