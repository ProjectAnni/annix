import 'package:animations/animations.dart';
import 'package:annix/providers.dart';
import 'package:annix/ui/dialogs/search_lyrics.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/loop_mode_button.dart';
import 'package:annix/ui/widgets/buttons/play_pause_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/playing_queue.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/utils/share.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:annix/i18n/strings.g.dart';

class PlayingScreenMobileBottomBar extends ConsumerWidget {
  final ValueNotifier<bool> showLyrics;

  const PlayingScreenMobileBottomBar({super.key, required this.showLyrics});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final delegate = ref.read(routerProvider);
    final player = ref.read(playbackProvider);

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
            final playing = player.playing?.track;
            if (playing != null) {
              showDialog(
                context: context,
                useRootNavigator: true,
                builder: (final context) {
                  return SearchLyricsDialog(track: playing);
                },
              );
            }
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
              leadingIcon: const Icon(Icons.album_outlined),
              child: Text(t.playing.view_album),
              onPressed: () async {
                // jump to album page
                delegate.to(
                  name: '/album',
                  arguments: player.playing!.track.id.albumId,
                );
                // hide playing page after navigation
                ref.read(routerProvider).slideController.hide();
                ref.read(routerProvider).panelController.close();
              },
            ),
            // const Divider(height: 1),
            MenuItemButton(
              leadingIcon: const Icon(Icons.share_outlined),
              child: Text(t.track.share),
              onPressed: () {
                final track = player.playing!.track;
                final box = context.findRenderObject() as RenderBox?;
                shareNowPlayingTrack(
                    track, box!.localToGlobal(Offset.zero) & box.size);
              },
            ),
          ],
          child: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }
}

class PlayingScreenMobileTrackInfo extends ConsumerWidget {
  const PlayingScreenMobileTrackInfo({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playing = ref.watch(playingProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          playing?.track.title ?? '',
          style: context.textTheme.titleLarge?.copyWith(
            height: 1.5,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        ArtistText(
          playing?.track.artist ?? '',
          style: context.textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
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

            return ProgressBar(
              progress: playing?.position ?? Duration.zero,
              total: playing?.duration ?? Duration.zero,
              onSeek: (final position) {
                player.seek(position);
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
            IconButton(
              icon: const Icon(Icons.queue_music_rounded),
              onPressed: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  clipBehavior: Clip.antiAlias,
                  builder: (final context) {
                    return DraggableScrollableSheet(
                      expand: false,
                      builder: (final context, final scrollController) {
                        return PlayingQueue(controller: scrollController);
                      },
                    );
                  },
                );
              },
            ),
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
  Widget build(final BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder:
          (final child, final primaryAnimation, final secondaryAnimation) {
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
