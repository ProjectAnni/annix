import 'package:annix/models/playlist.dart';
import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/material.dart';

typedef RepeatFunction = void Function(RepeatMode mode);

class RepeatButton extends StatefulWidget {
  final RepeatFunction? onRepeatModeChange;
  final RepeatMode? initial;

  RepeatButton({
    Key? key,
    this.initial,
    @required this.onRepeatModeChange,
  }) : super(key: key);

  @override
  _RepeatButtonState createState() => _RepeatButtonState();
}

class _RepeatButtonState extends State<RepeatButton> {
  late RepeatMode mode;

  @override
  void initState() {
    super.initState();
    mode = widget.initial ?? RepeatMode.Normal;
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    switch (mode) {
      case RepeatMode.Normal:
        icon = Icons.trending_neutral_rounded;
        break;
      case RepeatMode.Random:
        icon = Icons.shuffle;
        break;
      case RepeatMode.LoopOne:
        icon = Icons.repeat_one_rounded;
        break;
      case RepeatMode.Loop:
        icon = Icons.repeat_rounded;
        break;
    }

    return SquareIconButton(
        child: Icon(icon),
        onPressed: () {
          setState(() {
            switch (mode) {
              case RepeatMode.Normal:
                mode = RepeatMode.Loop;
                break;
              case RepeatMode.Loop:
                mode = RepeatMode.LoopOne;
                break;
              case RepeatMode.LoopOne:
                mode = RepeatMode.Random;
                break;
              case RepeatMode.Random:
                mode = RepeatMode.Normal;
                break;
            }
          });
          widget.onRepeatModeChange!(mode);
        });
  }
}
