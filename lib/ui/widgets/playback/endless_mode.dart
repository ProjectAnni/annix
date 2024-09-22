import 'dart:async';

import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback_service.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EndlessModeController extends ChangeNotifier {
  final Ref ref;

  bool enabled = false;
  int throttle = 5;
  Completer? _completer;

  EndlessModeController(this.ref) {
    ref.listen(playbackProvider, (_, player) => tryAppend(player, true));
  }

  Future<void> tryAppend(PlaybackService player, bool append) async {
    final currentPlayingIndex = player.playingIndex;
    if (enabled && (_completer == null || _completer!.isCompleted)) {
      final setNew = !append;
      final appendOld = append &&
          currentPlayingIndex != null &&
          currentPlayingIndex + throttle > player.queue.length;

      if (setNew || appendOld) {
        final completer = Completer();
        _completer = completer;
        // load more songs
        await player.fullShuffleMode(append: append);
        completer.complete();
      }
    }
  }

  Future<void> toggle(bool enable) async {
    enabled = enable;
    if (enabled) {
      final player = ref.read(playbackProvider);
      await tryAppend(player, false);
    }

    notifyListeners();
  }
}

class EndlessModeChip extends ConsumerWidget {
  const EndlessModeChip({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final controller = ref.watch(endlessModeProvider);

    return FilterChip(
      avatar: const Icon(Icons.loop_outlined),
      label: const Text('Endless Mode'),
      selected: controller.enabled,
      onSelected: (enable) async {
        if (enable) {
          showLoadingDialog(context);
        }
        await controller.toggle(enable);
        if (enable) {
          if (context.mounted) {
            context.pop();
          }
        }
      },
    );
  }
}
