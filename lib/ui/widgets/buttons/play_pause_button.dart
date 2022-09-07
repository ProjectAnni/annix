import 'package:annix/services/player.dart';
import 'package:annix/ui/widgets/buttons/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PlayPauseButtonType {
  floating,
  elevated,
  flat,
}

class PlayPauseButton extends StatefulWidget {
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
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    final player = Provider.of<PlayerService>(context, listen: false);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: player.playerStatus == PlayerStatus.playing ? 1 : 0,
    );
    player.addListener(() {
      if (player.playerStatus == PlayerStatus.playing) {
        _controller.forward();
      } else if (player.playerStatus == PlayerStatus.paused ||
          player.playerStatus == PlayerStatus.stopped) {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<PlayerService>(context, listen: false);
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Selector<PlayerService, bool>(
        selector: (context, player) =>
            player.playerStatus == PlayerStatus.buffering,
        builder: (context, isBuffering, child) {
          if (isBuffering) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else {
            if (widget.type == PlayPauseButtonType.floating) {
              return FloatingActionButton(
                child: AnimatedIconWidget(
                  controller: _controller,
                  icon: AnimatedIcons.play_pause,
                ),
                onPressed: () {
                  player.playOrPause();
                },
              );
            } else if (widget.type == PlayPauseButtonType.elevated) {
              return Card(
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: AnimatedIconWidget(
                      controller: _controller,
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
                  controller: _controller,
                  icon: AnimatedIcons.play_pause,
                ),
                onPressed: () {
                  player.playOrPause();
                },
              );
            }
          }
        },
      ),
    );
  }
}

// class PlayPauseButton extends StatelessWidget {
//   final double iconSize;
//   final bool fab;

//   const PlayPauseButton({
//     Key? key,
//     this.iconSize = 24,
//     this.fab = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: iconSize + 16,
//       width: iconSize + 16,
//       child: Consumer<PlayerService>(
//         builder: (context, playing, child) {
//           final status = playing.playerStatus;

//           if (status == PlayerStatus.buffering) {
//             return const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: CircularProgressIndicator(strokeWidth: 2),
//             );
//           } else {
//             return AnimatedSwitcher(duration: duration)
//             return FloatingActionButton(
//               child: AnimatedIconView(
//                 controller: AnimationController(),
//                 icon: AnimatedIcons.play_pause,
//               ),
//               // child: status == PlayerStatus.playing
//               //     ? const Icon(Icons.pause)
//               //     : const Icon(Icons.play_arrow),
//               onPressed: () {
//                 key.currentState!.toggle();
//                 playing.playOrPause();
//               },
//             );
//           }
//         },
//       ),
//     );

//     // return Material(
//     //   type: MaterialType.transparency,
//     //   child: Consumer<PlayerService>(
//     //     builder: (context, playing, child) {
//     //       final status = playing.playerStatus;
//     //       return SizedBox(
//     //         height: iconSize + 16,
//     //         width: iconSize + 16,
//     //         child: FloatingActionButton(
//     //           child: const Icon(Icons.search_outlined),
//     //           onPressed: () {
//     //             playing.playOrPause();
//     //           },
//     //         ),
//     //       );
//     //       if (status == PlayerStatus.buffering) {
//     //         return SizedBox(
//     //           height: iconSize + 16,
//     //           width: iconSize + 16,
//     //           child: const CircularProgressIndicator(strokeWidth: 2),
//     //         );
//     //       } else {
//     //         return IconButton(
//     //           isSelected: status == PlayerStatus.playing,
//     //           selectedIcon: const Icon(Icons.pause),
//     //           icon: const Icon(Icons.play_arrow),
//     //           iconSize: iconSize,
//     //           onPressed: () => playing.playOrPause(),
//     //         );
//     //       }
//     //     },
//     //   ),
//     // );
//   }
// }
