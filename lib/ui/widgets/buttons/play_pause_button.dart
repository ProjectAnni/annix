import 'package:annix/services/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayPauseButton extends StatelessWidget {
  final double iconSize;

  const PlayPauseButton({Key? key, this.iconSize = 24}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "play-pause-button",
      child: Material(
        type: MaterialType.transparency,
        child: Consumer<PlayerService>(
          builder: (context, playing, child) {
            final status = playing.playerStatus;
            if (status == PlayerStatus.buffering) {
              return SizedBox(
                height: iconSize + 16,
                width: iconSize + 16,
                child: const CircularProgressIndicator(strokeWidth: 2),
              );
            } else {
              return IconButton(
                isSelected: status == PlayerStatus.playing,
                selectedIcon: const Icon(Icons.pause),
                icon: const Icon(Icons.play_arrow),
                iconSize: iconSize,
                onPressed: () => playing.playOrPause(),
              );
            }
          },
        ),
      ),
    );
  }
}
