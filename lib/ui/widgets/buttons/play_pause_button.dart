import 'package:annix/providers.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/buttons/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PlayPauseButtonType {
  floating,
  elevated,
  flat,
}

class PlayPauseButton extends HookConsumerWidget {
  final double size;
  final PlayPauseButtonType type;

  const PlayPauseButton({super.key, required this.size, required this.type});

  factory PlayPauseButton.small() {
    return const PlayPauseButton(size: 40, type: PlayPauseButtonType.flat);
  }

  factory PlayPauseButton.large() {
    return const PlayPauseButton(size: 56, type: PlayPauseButtonType.floating);
  }

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final player = ref.watch(playbackProvider);
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
      initialValue: player.playerStatus == PlayerStatus.playing ? 1 : 0,
    );
    useEffect(() {
      if (player.playerStatus == PlayerStatus.playing) {
        controller.forward();
      } else if (player.playerStatus == PlayerStatus.paused ||
          player.playerStatus == PlayerStatus.stopped) {
        controller.reverse();
      }

      return null;
    }, [player.playerStatus]);

    final isBuffering = player.playerStatus == PlayerStatus.buffering;

    Widget child;
    if (isBuffering) {
      child = const Padding(
        padding: EdgeInsets.all(10.0),
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else {
      if (type == PlayPauseButtonType.floating) {
        return FloatingActionButton(
          child: AnimatedIconWidget(
            controller: controller,
            icon: AnimatedIcons.play_pause,
          ),
          onPressed: () {
            player.playOrPause();
          },
        );
      } else if (type == PlayPauseButtonType.elevated) {
        return Card(
          elevation: 2,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: AnimatedIconWidget(
                controller: controller,
                icon: AnimatedIcons.play_pause,
              ),
            ),
            onTap: () {
              player.playOrPause();
            },
          ),
        );
      } else {
        return IconButton(
          icon: AnimatedIconWidget(
            controller: controller,
            icon: AnimatedIcons.play_pause,
          ),
          onPressed: () {
            player.playOrPause();
          },
        );
      }
    }

    return SizedBox(
      height: size,
      width: size,
      child: child,
    );
  }
}
