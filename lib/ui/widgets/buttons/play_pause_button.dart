import 'package:annix/services/download/download_task.dart';
import 'package:annix/services/playback/playback.dart';
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

    final player = context.read<PlaybackService>();
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
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Consumer<PlaybackService>(
        builder: (context, player, child) {
          final isBuffering = player.playerStatus == PlayerStatus.buffering;
          final downloadTask = player.playing?.source.downloadTask;

          if (isBuffering && downloadTask != null) {
            return ChangeNotifierProvider.value(
              value: downloadTask,
              builder: (context, child) {
                return Consumer<DownloadTask>(
                  builder: (context, downloadTask, child) {
                    // TODO: add transition animation when progress bar becomes play/pause button
                    final total = downloadTask.progress.total;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: total == null
                            ? null
                            : downloadTask.progress.current / total,
                      ),
                    );
                  },
                );
              },
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
