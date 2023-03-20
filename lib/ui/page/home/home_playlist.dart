import 'package:annix/services/local/database.dart' hide Playlist;
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
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

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: albumId == null
                      ? const DummyMusicCover()
                      : MusicCover.fromAlbum(albumId: albumId),
                ),
                title: Text(
                  playlist.name,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async {
                  final delegate = AnnixRouterDelegate.of(context);
                  final list = await Playlist.load(playlist.id);
                  delegate.to(name: '/playlist', arguments: list);
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
