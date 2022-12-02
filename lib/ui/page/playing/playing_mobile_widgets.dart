import 'package:animations/animations.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/dialogs/playing_more_menu.dart';
import 'package:annix/ui/dialogs/search_lyrics.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/drag_handle.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/playing_queue.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:provider/provider.dart';

class PlayingScreenMobileBottomBar extends StatelessWidget {
  final ValueNotifier<bool> showLyrics;

  const PlayingScreenMobileBottomBar({super.key, required this.showLyrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          child: IconButton(
            icon: const Icon(Icons.text_snippet_rounded),
            onPressed: () {
              showLyrics.value = !showLyrics.value;
            },
          ),
          onLongPress: () {
            final player = context.read<PlaybackService>();
            final playing = player.playing?.track;
            if (playing != null) {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (context) {
                  return SearchLyricsDialog(track: playing);
                },
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.queue_music_rounded),
          onPressed: () {
            showModalBottomSheet(
              useRootNavigator: true,
              context: context,
              isScrollControlled: true,
              clipBehavior: Clip.antiAlias,
              builder: (context) {
                return DraggableScrollableSheet(
                  expand: false,
                  builder: (context, scrollController) {
                    return Column(
                      children: [
                        const DragHandle(),
                        Expanded(
                          child: PlayingQueue(controller: scrollController),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded),
          onPressed: () {
            showModalBottomSheet(
              useRootNavigator: true,
              context: context,
              isScrollControlled: true,
              builder: (context) {
                final player = context.read<PlaybackService>();
                return PlayingMoreMenu(track: player.playing!.track);
              },
            );
          },
        ),
      ],
    );
  }
}

class PlayingScreenMobileTrackInfo extends StatelessWidget {
  const PlayingScreenMobileTrackInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<PlaybackService>(
          builder: (context, player, child) => Center(
            child: Text(
              player.playing?.track.title ?? '',
              style: context.textTheme.titleLarge?.copyWith(height: 1.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Consumer<PlaybackService>(
          builder: (context, player, child) => ArtistText(
            player.playing?.track.artist ?? '',
            style: context.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class PlayingScreenMobileControl extends StatelessWidget {
  const PlayingScreenMobileControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<PlaybackService>(
          builder: (context, player, child) {
            return ChangeNotifierProvider.value(
              value: player.playing,
              child: Consumer<PlayingTrack?>(
                builder: (context, playing, child) {
                  return ProgressBar(
                    progress: playing?.position ?? Duration.zero,
                    total: playing?.duration ?? Duration.zero,
                    onSeek: (position) {
                      player.seek(position);
                    },
                    barHeight: 2.0,
                    thumbRadius: 5.0,
                    thumbCanPaintOutsideBar: false,
                  );
                },
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const FavoriteButton(),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 32,
              onPressed: () => context.read<PlaybackService>().previous(),
            ),
            PlayPauseButton.large(),
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 32,
              onPressed: () => context.read<PlaybackService>().next(),
            ),
            const LoopModeButton(),
          ],
        ),
      ],
    );
  }
}

class MusicCoverOrLyric extends StatefulWidget {
  final ValueListenable<bool> showLyric;
  final Color fillColor;

  const MusicCoverOrLyric(
      {super.key,
      required this.showLyric,
      this.fillColor = Colors.transparent});

  @override
  State<MusicCoverOrLyric> createState() => _MusicCoverOrLyricState();
}

class _MusicCoverOrLyricState extends State<MusicCoverOrLyric> {
  bool showLyric = false;

  @override
  void initState() {
    super.initState();

    widget.showLyric.addListener(onShowLyricsChange);
  }

  @override
  void dispose() {
    super.dispose();

    widget.showLyric.removeListener(onShowLyricsChange);
  }

  onShowLyricsChange() {
    setState(() {
      showLyric = widget.showLyric.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: widget.fillColor,
          child: child,
        );
      },
      child: IndexedStack(
        index: showLyric ? 0 : 1,
        key: ValueKey(showLyric ? 0 : 1),
        children: const [
          AspectRatio(
            aspectRatio: 1,
            child: LyricView(
              alignment: LyricAlign.CENTER,
            ),
          ),
          PlayingMusicCover(),
        ],
      ),
    );
  }
}
