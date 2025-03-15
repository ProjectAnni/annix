import 'package:annix/providers.dart';
import 'package:annix/ui/dialogs/playlist_dialog.dart';
import 'package:annix/ui/dialogs/search_lyrics.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/fade_indexed_stack.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/slide_up.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/utils/share.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:annix/i18n/strings.g.dart';

class PlayingScreenMobileBottomBar extends ConsumerWidget {
  final ValueNotifier<bool> showLyrics;

  const PlayingScreenMobileBottomBar({super.key, required this.showLyrics});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final player = ref.read(playbackProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: ref.read(routerProvider).closePanel,
        ),
        OverflowBar(
          children: [
            GestureDetector(
              child: IconButton(
                icon: const Icon(Icons.text_snippet_rounded),
                onPressed: () {
                  showLyrics.value = !showLyrics.value;
                },
              ),
              onLongPress: () {
                final playing = player.playing.source?.track;
                if (playing != null) {
                  showDialog(
                    context: context,
                    builder: (final context) {
                      return SearchLyricsDialog(track: playing);
                    },
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.queue_music_rounded),
              onPressed: () {
                context.go('/music');
              },
            ),
            MenuAnchor(
              // alignmentOffset: const Offset(-64, 0),
              // style: MenuStyle(
              //   padding:
              //       MaterialStateProperty.resolveWith((states) => EdgeInsets.zero),
              //   shape: MaterialStateProperty.resolveWith(
              //     (states) => RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20)),
              //   ),
              // ),
              builder: (final context, final controller, final child) {
                return IconButton(
                  icon: child!,
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                );
              },
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.playlist_add),
                  child: Text(t.track.add_to_playlist),
                  onPressed: () {
                    showPlaylistDialog(
                        context, ref, player.playing.source!.identifier);
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.album_outlined),
                  child: Text(t.playing.view_album),
                  onPressed: () {
                    // jump to album page
                    context.replace(
                      '/album',
                      extra: player.playing.source!.identifier.albumId,
                    );
                    // hide self
                    ref.read(routerProvider).closePanel();
                  },
                ),
                // const Divider(height: 1),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.share_outlined),
                  child: Text(t.track.share),
                  onPressed: () {
                    final track = player.playing.source!.track;
                    final box = context.findRenderObject() as RenderBox?;
                    shareTrackInfo(
                      track,
                      box!.localToGlobal(Offset.zero) & box.size,
                      nowPlaying: true,
                    );
                  },
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.file_copy),
                  child: const Text('[DEV] Export file'),
                  onPressed: () {
                    final track = player.playing.source!.track;
                    final box = context.findRenderObject() as RenderBox?;
                    shareTrackFile(
                      track,
                      box!.localToGlobal(Offset.zero) & box.size,
                    );
                  },
                ),
              ],
              child: const Icon(Icons.more_vert_rounded),
            ),
          ],
        )
      ],
    );
  }
}

class PlayingScreenMobileTrackInfo extends ConsumerWidget {
  const PlayingScreenMobileTrackInfo({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final source = ref.watch(playingProvider.select((p) => p.source));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source?.track.title ?? '',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        ArtistText(
          source?.track.artist ?? '',
          style: context.textTheme.bodyLarge,
          overflow: TextOverflow.ellipsis,
          search: true,
        )
      ],
    );
  }
}

class PlayingScreenMobileControl extends ConsumerWidget {
  const PlayingScreenMobileControl({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final player = ref.read(playbackProvider);

    return Column(
      children: [
        Consumer(
          builder: (final context, final ref, final child) {
            final playing = ref.watch(playingProvider);

            return HorizontalScrollableWidget(
              child: ProgressBar(
                progress: playing.position,
                total: playing.duration == Duration.zero
                    ? playing.position
                    : playing.duration,
                onSeek: (final position) {
                  player.seek(position);
                },
                timeLabelTextStyle: context.textTheme.labelLarge,
                timeLabelLocation: TimeLabelLocation.below,
                thumbCanPaintOutsideBar: false,
                timeLabelType: TimeLabelType.totalTime,
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const LoopModeButton(),
            IconButton(
              icon: const Icon(Icons.skip_previous),
              iconSize: 32,
              onPressed: player.previous,
            ),
            PlayPauseButton.large(),
            IconButton(
              icon: const Icon(Icons.skip_next),
              iconSize: 32,
              onPressed: player.next,
            ),
            const ShuffleModeButton(),
          ],
        ),
      ],
    );
  }
}

class MusicCoverOrLyric extends StatelessWidget {
  final ValueListenable<bool> showLyric;

  const MusicCoverOrLyric({
    super.key,
    required this.showLyric,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: FadeIndexedStack(
        index: showLyric.value ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        children: const [
          LyricView(),
          Center(child: PlayingMusicCover()),
        ],
      ),
    );
  }
}
