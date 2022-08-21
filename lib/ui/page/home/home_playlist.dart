import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivService>(context, listen: false);
    return Consumer<List<PlaylistData>>(
      builder: (context, playlists, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                // fav
                return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: anniv.favorites.isEmpty
                          ? const DummyMusicCover()
                          : MusicCover(
                              albumId:
                                  anniv.favorites.values.last.track.albumId),
                    ),
                    title: Text(I18n.MY_FAVORITE.tr),
                    visualDensity: VisualDensity.standard,
                    onTap: () {
                      AnnixRouterDelegate.of(context).to(name: "/favorite");
                    });
              } else {
                index = index - 1;
              }

              final playlistId = playlists[index].remoteId;
              final playlist = playlists[index];

              final albumId =
                  playlist.cover == null ? null : playlist.cover!.split('/')[0];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                visualDensity: VisualDensity.standard,
                onTap: () async {
                  final delegate = AnnixRouterDelegate.of(context);
                  final playlist = await anniv.getPlaylist(playlistId ?? ""); // FIXME
                  delegate.to(name: "/playlist", arguments: playlist);
                },
              );
            },
            childCount: playlists.length + 1,
          ),
        );
      },
    );
  }
}
