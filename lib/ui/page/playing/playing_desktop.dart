import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/tag.dart';
import 'package:annix/ui/widgets/lyric.dart';
import 'package:annix/pages/playlist/playlist_album.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_lyric/lyric_ui/lyric_ui.dart';

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
                      GetBuilder<PlayerController>(
                        builder: (player) {
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
                      GetBuilder<PlayerController>(
                        builder: (player) => ButtonBar(
                          buttonPadding: EdgeInsets.zero,
                          alignment: MainAxisAlignment.start,
                          children: [
                            TextButton.icon(
                              icon: Icon(Icons.person_outline),
                              label: ArtistText(
                                  player.playing?.track.artist ?? "",
                                  expandable: false),
                              onPressed: () {
                                AnnixBodyPageRouter.to(
                                  () => TagScreen(
                                    name: player.playing!.track.artist,
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: Icon(
                                Icons.album_outlined,
                                size: 20,
                              ),
                              label: Text(
                                  player.playing?.track.disc.album.title ?? ""),
                              onPressed: () {
                                AnnixBodyPageRouter.to(
                                  () => AlbumDetailScreen(
                                    album: player.playing!.track.disc.album,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
