import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayingDesktopScreen extends StatefulWidget {
  const PlayingDesktopScreen({super.key});

  @override
  State<PlayingDesktopScreen> createState() => _PlayingDesktopScreenState();
}

class _PlayingDesktopScreenState extends State<PlayingDesktopScreen> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Expanded(
            flex: 10,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 600),
                child: PlayingMusicCover(
                  card: true,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
          ),
          Spacer(),
          Expanded(
            flex: 8,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Consumer(
                  builder: (final context, final ref, final child) {
                    final track = ref.watch(
                        playingProvider.select((final p) => p.source?.track));
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        track?.title ?? '',
                        style: context.textTheme.titleLarge!.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                        maxLines: 1,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer(
                  builder: (final context, final ref, final child) {
                    final track = ref.watch(
                        playingProvider.select((final p) => p.source?.track));
                    if (track == null) {
                      return const SizedBox.shrink();
                    }

                    return OverflowBar(
                      spacing: 0,
                      alignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          icon: const Icon(
                            Icons.person_outline,
                            size: 20,
                          ),
                          label: ArtistText(
                            track.artist,
                            expandable: false,
                            search: true,
                          ),
                          onPressed: () {
                            // FIXME: dialog to show all available tags
                            context.push('/tag', extra: track.artist);
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(
                            Icons.album_outlined,
                            size: 20,
                          ),
                          label: Text(
                            track.albumTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onPressed: () {
                            context.push(
                              '/album',
                              extra: track.id.albumId,
                            );
                          },
                        ),
                        // FIXME: tags list
                        // ...<String>{
                        //   ...(metadata.tags ?? []),
                        //   ...(metadata.disc.tags ?? []),
                        //   ...(metadata.disc.album.tags ?? [])
                        // }.map(
                        //   (tag) => TextButton.icon(
                        //     icon: const Icon(
                        //       Icons.local_offer_outlined,
                        //       size: 20,
                        //     ),
                        //     label: Text(tag),
                        //     onPressed: () {
                        //       AnnixRouterDelegate.of(context).to(
                        //         name: '/tag',
                        //         arguments: tag,
                        //       );
                        //     },
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: LyricView(alignment: LyricAlign.LEFT),
                  ),
                ),
                Spacer()
              ],
            ),
          ),
          // Container(
          //   width: 64,
          //   alignment: Alignment.bottomCenter,
          //   child: OverflowBar(
          //     alignment: MainAxisAlignment.end,
          //     children: [
          //       Consumer(
          //         builder: (final context, final ref, final child) {
          //           return IconButton(
          //             icon: const Icon(Icons.lyrics_outlined),
          //             onPressed: () {
          //               final player = ref.read(playbackProvider);
          //               final playing = player.playing.source?.track;
          //               if (playing != null) {
          //                 showDialog(
          //                   context: context,
          //                   builder: (final context) {
          //                     return SearchLyricsDialog(track: playing);
          //                   },
          //                 );
          //               }
          //             },
          //           );
          //         },
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
