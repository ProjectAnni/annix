import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoopModeButton extends ConsumerWidget {
  const LoopModeButton({super.key});

  // TODO: move getIcon and next to LoopMode
  Icon getIcon(final LoopMode loopMode, {final Color? inactiveColor}) {
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

  LoopMode next(final LoopMode loopMode) {
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
  Widget build(final BuildContext context, final WidgetRef ref) {
    final loopMode =
        ref.watch(playbackProvider.select((final p) => p.loopMode));
    final playback = ref.read(playbackProvider);
    return IconButton(
      icon: getIcon(
        loopMode,
        inactiveColor: context.theme.iconTheme.color?.withOpacity(0.3),
      ),
      onPressed: () {
        playback.setLoopMode(next(loopMode));
      },
    );
  }
}
