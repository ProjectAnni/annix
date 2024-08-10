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
      icon: loopMode.getIcon(
        inactiveColor: context.theme.iconTheme.color?.withOpacity(0.3),
      ),
      onPressed: () {
        ref.read(playbackProvider).setLoopMode(loopMode.next());
      },
    );
  }
}
