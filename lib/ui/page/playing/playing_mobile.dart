import 'package:animations/animations.dart';
import 'package:annix/services/player.dart';
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

class PlayingScreenMobile extends StatefulWidget {
  const PlayingScreenMobile({super.key});

  @override
  State<PlayingScreenMobile> createState() => _PlayingScreenMobileState();
}

class _PlayingScreenMobileState extends State<PlayingScreenMobile> {
  bool showLyrics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.colorScheme.secondaryContainer,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PageTransitionSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder:
                  (widget, primaryAnimation, secondaryAnimation) {
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
                Consumer<PlayerService>(
                  builder: (context, player, child) => Center(
                    child: Text(
                      player.playing?.track.title ?? "",
                      style: context.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Consumer<PlayerService>(
                  builder: (context, player, child) => ArtistText(
                    player.playing?.track.artist ?? "",
                    style: context.textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Consumer<PlayerService>(
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
                      onPressed: () =>
                          Provider.of<PlayerService>(context, listen: false)
                              .previous(),
                    ),
                    PlayPauseButton.large(),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 32,
                      onPressed: () =>
                          Provider.of<PlayerService>(context, listen: false)
                              .next(),
                    ),
                    const LoopModeButton(),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
      bottomSheet: BottomAppBar(
        elevation: 5,
        color: context.colorScheme.secondaryContainer,
        child: ButtonBar(
          alignment: MainAxisAlignment.end,
          buttonPadding: EdgeInsets.zero,
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
                final player =
                    Provider.of<PlayerService>(context, listen: false);
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: context.colorScheme.surface,
                  elevation: 1,
                  useRootNavigator: true,
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
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    final player =
                        Provider.of<PlayerService>(context, listen: false);
                    return FractionallySizedBox(
                      heightFactor: 0.7,
                      child: PlayingMoreMenu(track: player.playing!.track),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
