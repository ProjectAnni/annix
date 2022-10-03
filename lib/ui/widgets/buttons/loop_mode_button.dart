import 'package:annix/services/playback/playback.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoopModeButton extends StatelessWidget {
  const LoopModeButton({Key? key}) : super(key: key);

  Icon getIcon(LoopMode loopMode, {Color? inactiveColor}) {
    switch (loopMode) {
      case LoopMode.off:
        return Icon(Icons.repeat, color: inactiveColor);
      case LoopMode.all:
        return const Icon(Icons.repeat);
      case LoopMode.one:
        return const Icon(Icons.repeat_one);
      case LoopMode.random:
        return const Icon(Icons.shuffle);
    }
  }

  LoopMode next(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return LoopMode.all;
      case LoopMode.all:
        return LoopMode.one;
      case LoopMode.one:
        return LoopMode.random;
      case LoopMode.random:
        return LoopMode.off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<PlaybackService, LoopMode>(
      selector: (_, player) => player.loopMode,
      builder: (_, loopMode, child) => IconButton(
        icon: getIcon(
          loopMode,
          inactiveColor: context.theme.iconTheme.color?.withOpacity(0.3),
        ),
        onPressed: () {
          context.read<PlaybackService>().setLoopMode(next(loopMode));
        },
      ),
    );
  }
}
