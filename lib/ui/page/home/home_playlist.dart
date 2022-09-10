import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<List<PlaylistData>>(
      builder: (context, playlists, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                // fav
                return Consumer<List<Favorite>>(
                  builder: (context, favorites, child) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: favorites.isEmpty
                            ? const DummyMusicCover()
                            : MusicCover(albumId: favorites.last.albumId),
                      ),
                      title: Text(I18n.MY_FAVORITE.tr),
                      visualDensity: VisualDensity.standard,
                      onTap: () {
                        AnnixRouterDelegate.of(context).to(name: "/favorite");
                      },
                    );
                  },
                );
              } else {
                index = index - 1;
              }

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
                  delegate.to(name: "/playlist", arguments: playlist.id);
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
