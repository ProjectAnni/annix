import 'package:annix/providers.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoopModeButton extends ConsumerWidget {
  const LoopModeButton({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final loopMode =
        ref.watch(playbackProvider.select((final p) => p.loopMode));
    return IconButton(
      icon: loopMode.getIcon(activeColor: context.colorScheme.primary),
      onPressed: () {
        ref.read(playbackProvider).setLoopMode(loopMode.next());
      },
    );
  }
}

class ShuffleModeButton extends ConsumerWidget {
  const ShuffleModeButton({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final shuffleMode =
        ref.watch(playbackProvider.select((final p) => p.shuffleMode));
    return IconButton(
      icon: shuffleMode.getIcon(activeColor: context.colorScheme.primary),
      onPressed: () {
        ref.read(playbackProvider).setShuffleMode(shuffleMode.next());
      },
    );
  }
}
