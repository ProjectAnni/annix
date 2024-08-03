import 'package:annix/i18n/strings.g.dart';
import 'package:flutter/material.dart';

class PlayShuffleButtonGroup extends StatelessWidget {
  final bool stretch;
  final VoidCallback? onPlay;
  final VoidCallback? onShufflePlay;

  const PlayShuffleButtonGroup({
    super.key,
    this.onPlay,
    this.onShufflePlay,
    this.stretch = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (final context, final constraints) {
      double? maxWidth;
      if (stretch && constraints.maxWidth != double.infinity) {
        maxWidth = constraints.maxWidth / 2.2;
      }

      return ButtonBar(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        alignment: stretch ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(t.playback.play_all),
              onPressed: onPlay,
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: FilledButton.icon(
              icon: const Icon(Icons.shuffle),
              label: Text(t.playback.shuffle),
              onPressed: onShufflePlay,
            ),
          ),
        ],
      );
    });
  }
}
