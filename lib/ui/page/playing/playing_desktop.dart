import 'package:annix/services/player.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';
import 'package:provider/provider.dart';

class PlayingDesktopScreen extends StatelessWidget {
  PlayingDesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Spacer(),
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Center(child: PlayingMusicCover(card: true)),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<PlayerService>(
                        builder: (context, player, child) {
                          return TextButton(
                            child: Text(
                              player.playing?.track.title ?? "",
                              style: context.textTheme.titleLarge!.copyWith(
                                color: context
                                    .theme.colorScheme.onPrimaryContainer,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () {
                              // TODO: copy track title
                            },
                          );
                        },
                      ),
                      SizedBox(height: 4),
                      Consumer<PlayerService>(
                        builder: (context, player, child) {
                          final metadata = player.playing?.track;
                          if (metadata == null) {
                            return SizedBox.shrink();
                          }

                          return ButtonBar(
                            buttonPadding: EdgeInsets.zero,
                            alignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                icon: Icon(Icons.person_outline),
                                label: ArtistText(
                                  metadata.artist,
                                  expandable: false,
                                ),
                                onPressed: () {},
                              ),
                              TextButton.icon(
                                icon: Icon(
                                  Icons.album_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  metadata.disc.album.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onPressed: () {
                                  AnnixRouterDelegate.of(context).to(
                                    name: '/album',
                                    arguments: metadata.disc.album,
                                  );
                                },
                              ),
                              ...Set.from([
                                ...(metadata.tags ?? []),
                                ...(metadata.disc.tags ?? []),
                                ...(metadata.disc.album.tags ?? [])
                              ]).map(
                                (tag) => TextButton.icon(
                                  icon: Icon(
                                    Icons.local_offer_outlined,
                                    size: 20,
                                  ),
                                  label: Text(tag),
                                  onPressed: () {
                                    AnnixRouterDelegate.of(context).to(
                                      name: '/tag',
                                      arguments: tag,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: LyricView(alignment: LyricAlign.LEFT),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(flex: 1),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
