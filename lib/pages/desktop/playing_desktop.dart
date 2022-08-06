import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/playing/playing_lyric.dart';
import 'package:annix/pages/playing/playing_queue.dart';
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded(
          //   flex: 4,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Expanded(
          //         child: Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 8),
          //           child: PlayingQueue(),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 256,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Card(
                      elevation: 4,
                      clipBehavior: Clip.hardEdge,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: PlayingMusicCover(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(flex: 3),
                GetBuilder<PlayerController>(
                  builder: (player) {
                    return TextButton(
                      child: Text(
                        player.playing?.track.title ?? "",
                        style: context.textTheme.titleLarge!.copyWith(
                          color: context.theme.colorScheme.onPrimaryContainer,
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
                        label: ArtistText(player.playing?.track.artist ?? "", expandable: false),
                        onPressed: () {
                          // TODO: jump to tag if exists
                        },
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.album_outlined,
                          size: 20,
                        ),
                        label:
                            Text(player.playing?.track.disc.album.title ?? ""),
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
                Spacer(),
                Expanded(
                  flex: 8,
                  child: PlayingLyric(alignment: LyricAlign.LEFT),
                ),
                Spacer(),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
