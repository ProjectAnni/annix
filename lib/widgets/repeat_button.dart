import 'package:annix/widgets/square_icon_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

enum RepeatMode {
  Normal,
  Random,
  LoopOne,
  Loop,
}

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

  IconData _currentIcon(BuildContext context) {
    switch (mode) {
      case RepeatMode.Normal:
        return Icons.repeat_on_outlined;
      case RepeatMode.Random:
        return Icons.shuffle_outlined;
      case RepeatMode.LoopOne:
        return Icons.repeat_one_outlined;
      case RepeatMode.Loop:
        return Icons.repeat_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SquareIconButton(
      child: Icon(_currentIcon(context)),
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
      },
    );
  }
}
