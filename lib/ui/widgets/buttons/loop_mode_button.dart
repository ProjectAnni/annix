import 'package:annix/services/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoopModeButton extends StatelessWidget {
  const LoopModeButton({Key? key}) : super(key: key);

  Icon getIcon(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.off:
        return const Icon(Icons.next_plan_outlined);
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
    return Selector<PlayerService, LoopMode>(
      selector: (context, player) => player.loopMode,
      builder: (context, loopMode, child) => IconButton(
        icon: getIcon(loopMode),
        onPressed: () {
          context.read<PlayerService>().setLoopMode(next(loopMode));
        },
      ),
    );
  }
}
