import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/page/playlist.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> showPlaylistDialog(
  final BuildContext context,
  final WidgetRef ref,
  final TrackIdentifier track,
) async {
  final playlistsRaw = ref.watch(playlistProvider);
  final playlists = playlistsRaw.value ?? [];

  final anniv = ref.read(annivProvider);

  // hide the previous dialog
  Navigator.of(context, rootNavigator: true).pop();

  return showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (final context) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (final context, final scrollController) {
          return ListView(
            controller: scrollController,
            children: [
              const ListTile(
                leading: Icon(Icons.add),
                title: Text('Create Playlist'),
                subtitle: Text('Not working yet'),
              ),
              ...playlists.map(
                (playlistInfo) {
                  final playlist = PlaylistInfo.fromData(playlistInfo);
                  return ListTile(
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: playlist.cover == null
                          ? const DummyMusicCover()
                          : MusicCover.fromAlbum(
                              albumId: playlist.cover!.albumId),
                    ),
                    title: Text(playlist.name),
                    onTap: () async {
                      // TODO: show progress indicator
                      await anniv.appendTrackToPlaylist(
                        playlist,
                        track,
                      );
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
                      // refresh playlist family
                      ref.invalidate(playlistFamily);
                    },
                  );
                },
              ).toList(),
            ],
          );
        },
      );
    },
  );
}
