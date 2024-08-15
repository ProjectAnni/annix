import 'package:annix/i18n/strings.g.dart';
import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/dialogs/input_dialog.dart';
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
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                leading: const CoverCard(child: Icon(Icons.add)),
                title: Text(t.playlist.create_new),
                onTap: () async {
                  // show dialog to input playlist name
                  // TODO: input more info
                  final playlistName = await showInputDialog(
                    context,
                    t.playlist.create_new,
                    t.playlist.title,
                  );
                  if (playlistName != null) {
                    final anniv = ref.read(annivProvider);
                    await anniv.createPlaylist(
                        name: playlistName,
                        description: '',
                        items: [AnnivPlaylistItemPlainTrack(track: track)]);

                    // hide dialog
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.playlist.created)),
                      );
                    }
                    // refresh playlist family
                    ref.invalidate(playlistFamily);
                  }
                },
              ),
              const Divider(),
              ...playlists.map(
                (playlistInfo) {
                  final playlist = PlaylistInfo.fromData(playlistInfo);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 16.0,
                    ),
                    leading: CoverCard(
                      child: playlist.cover == null
                          ? const DummyMusicCover()
                          : MusicCover.fromAlbum(
                              albumId: playlist.cover!.albumId),
                    ),
                    title: Text(
                      playlist.name,
                      maxLines: 2,
                    ),
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
