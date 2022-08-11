import 'package:annix/services/player.dart';
import 'package:annix/pages/playing/playing_queue.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:annix/widgets/buttons/loop_mode_button.dart';
import 'package:annix/widgets/buttons/play_pause_button.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart' show Obx;
import 'package:get/get_rx/get_rx.dart';
import 'package:provider/provider.dart';

class PlayingMobileScreen extends StatelessWidget {
  final RxBool showLyrics = false.obs;

  PlayingMobileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onVerticalDragEnd: (details) {
                if ((details.primaryVelocity ?? 0) > 300) {
                  AnnixRouterDelegate.of(context).popRoute();
                }
              },
              child: Obx(
                () => showLyrics.value
                    ? const AspectRatio(
                        aspectRatio: 1,
                        child: LyricView(
                          alignment: LyricAlign.CENTER,
                        ),
                      )
                    : PlayingMusicCover(),
              ),
            ),
            Column(
              children: [
                Consumer<PlayerService>(
                  builder: (context, player, child) => Center(
                    child: Text(
                      player.playing?.track.title ?? "",
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Consumer<PlayerService>(
                  builder: (context, player, child) => ArtistText(
                    player.playing?.track.artist ?? "",
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Consumer<PlayingProgress>(
                  builder: (context, progress, child) {
                    return ProgressBar(
                      progress: progress.position,
                      total: progress.duration,
                      onSeek: (position) {
                        Provider.of<PlayerService>(context, listen: false)
                            .seek(position);
                      },
                      barHeight: 2.0,
                      thumbRadius: 5.0,
                      thumbCanPaintOutsideBar: false,
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FavoriteButton(),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 32,
                      onPressed: () =>
                          Provider.of<PlayerService>(context, listen: false)
                              .previous(),
                    ),
                    const PlayPauseButton(iconSize: 48),
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
        elevation: 4,
        child: ButtonBar(
          alignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.text_snippet_rounded),
              onPressed: () {
                showLyrics.value = !showLyrics.value;
              },
            ),
            IconButton(
              icon: const Icon(Icons.queue_music_rounded),
              onPressed: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  useSafeArea: true,
                  context: context,
                  builder: (context) {
                    return const PlayingQueue();
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
