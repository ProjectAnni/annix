import 'package:animations/animations.dart';
import 'package:annix/services/local/database.dart' hide Playlist;
import 'package:annix/ui/page/playlist/playlist_page_list.dart';
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

              return OpenContainer(
                openElevation: 0,
                openColor: Colors.transparent,
                closedElevation: 0,
                closedColor: Colors.transparent,
                closedShape: const RoundedRectangleBorder(),
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) {
                  return DisplayOrLazyLoadScreen<Playlist>(
                    future: loadPlaylist(playlist.id),
                    builder: (playlist) {
                      return PlaylistDetailScreen(playlist: playlist);
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
