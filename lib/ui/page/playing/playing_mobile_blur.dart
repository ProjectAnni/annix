import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/dialogs/playing_more_menu.dart';
import 'package:annix/ui/widgets/playing_queue.dart';
import 'package:annix/ui/dialogs/search_lyrics.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:provider/provider.dart';

class PlayingScreenMobileBlur extends StatefulWidget {
  const PlayingScreenMobileBlur({super.key});

  @override
  State<PlayingScreenMobileBlur> createState() =>
      _PlayingScreenMobileBlurState();
}

class _PlayingScreenMobileBlurState extends State<PlayingScreenMobileBlur> {
  bool showLyrics = false;

  Widget _mainPlayingWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(height: 0),
        PageTransitionSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (widget, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              fillColor: context.colorScheme.secondaryContainer,
              child: widget,
            );
          },
          child: IndexedStack(
            index: showLyrics ? 0 : 1,
            key: ValueKey(showLyrics ? 0 : 1),
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
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<PlaybackService>(
              builder: (context, player, child) => Center(
                child: Text(
                  player.playing?.track.title ?? '',
                  style: context.textTheme.titleLarge,
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
        ),
        Column(
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
        ),
        _bottomBar(),
      ],
    );
  }

  Widget _bottomBar() {
    return Material(
      // color: context.colorScheme.secondaryContainer,
      color: Colors.transparent,
      // type: MaterialType.canvas,
      // elevation: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            child: IconButton(
              icon: const Icon(Icons.text_snippet_rounded),
              onPressed: () {
                setState(() {
                  showLyrics = !showLyrics;
                });
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
                useSafeArea: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                useRootNavigator: true,
                backgroundColor: context.colorScheme.surface,
                context: context,
                builder: (context) {
                  return const PlayingQueue();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {
              showModalBottomSheet(
                useSafeArea: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                useRootNavigator: true,
                backgroundColor: context.colorScheme.surface,
                context: context,
                builder: (context) {
                  final player = context.read<PlaybackService>();
                  return PlayingMoreMenu(track: player.playing!.track);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: const PlayingMusicCover(
              animated: false,
              card: false,
              fit: BoxFit.cover,
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(
              // color: context.colorScheme.secondaryContainer,
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: _mainPlayingWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
