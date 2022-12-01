import 'package:animations/animations.dart';
import 'package:annix/global.dart';
import 'package:annix/services/local/database.dart' hide Playlist;
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/utils/display_or_lazy_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<List<PlaylistData>>(
      builder: (context, playlists, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final playlist = playlists[index];

              final albumId =
                  playlist.cover == null ? null : playlist.cover!.split('/')[0];

              // FIXME: animation size is not correct
              return OpenContainer(
                tappable: false,
                openElevation: 0,
                closedElevation: 0,
                openColor: Colors.transparent,
                closedColor: Colors.transparent,
                middleColor: Colors.transparent,
                closedShape: const RoundedRectangleBorder(),
                transitionType: ContainerTransitionType.fade,
                onClosed: (result) {
                  Global.mobileWeSlideFooterController.show();
                },
                openBuilder: (context, _) {
                  return DisplayOrLazyLoadScreen<Playlist>(
                    future: Playlist.load(playlist.id),
                    builder: (playlist) {
                      return PlaylistPage(playlist: playlist);
                    },
                  );
                },
                closedBuilder: (context, open) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: albumId == null
                          ? const DummyMusicCover()
                          : MusicCover(albumId: albumId),
                    ),
                    title: Text(
                      playlist.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Global.mobileWeSlideFooterController.hide();
                      open();
                    },
                  );
                },
              );
            },
            childCount: playlists.length,
          ),
        );
      },
    );
  }
}
