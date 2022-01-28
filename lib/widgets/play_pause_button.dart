import 'package:annix/services/audio.dart';
import 'package:annix/services/global.dart';
import 'package:annix/utils/platform_icons.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/widgets.dart';
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
            value.state.playing ? context.icons.pause : context.icons.playArrow,
            size: widget.size,
          ),
          onPressed: () async {
            if (value.state.playing) {
              Global.audioService.pause();
            } else {
              Global.audioService.play();
            }
          },
        );
      },
    );
  }
}
