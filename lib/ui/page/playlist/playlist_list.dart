import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/page/playlist/playlist.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends PlaylistScreen {
  final Playlist playlist;

  @override
  final Widget? pageTitle = null;
  @override
  final List<Widget>? pageActions = null;
  @override
  final RefreshCallback? refresh = null;

  const PlaylistDetailScreen({super.key, required this.playlist});

  static Future<PlaylistDetailScreen?> remote(String id) async {
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);
    final playlist = await anniv.getPlaylist(id);
    if (playlist == null) return null;
    return PlaylistDetailScreen(playlist: playlist);
  }

  @override
  String get title => playlist.intro.name;

  @override
  Widget get cover {
    final albumId = playlist.intro.cover.albumId == ""
        ? firstAvailableCover()
        : playlist.intro.cover.albumId;
    if (albumId == null) {
      return const DummyMusicCover();
    } else {
      return MusicCover(albumId: albumId);
    }
  }

  @override
  List<Widget> get intro => [
        // description
        ...(playlist.intro.description != null
            ? [Text(playlist.intro.description!)]
            : []),
      ];

  @override
  Widget get body {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);

    return ListView.builder(
      itemCount: playlist.items.length,
      itemBuilder: (context, index) {
        final track = playlist.items[index];
        return ListTile(
          leading: Text("${index + 1}"),
          minLeadingWidth: 16,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text('${track.info.title}', overflow: TextOverflow.ellipsis),
          subtitle: track.description != null && track.description!.isNotEmpty
              ? ArtistText(track.description!)
              : null,
          enabled: annil.isAvailable(
            albumId: track.info.track.albumId,
            discId: track.info.track.discId,
            trackId: track.info.track.trackId,
          ),
        );
      },
    );
  }

  @override
  List<TrackIdentifier> get tracks => playlist.items
      .map<TrackIdentifier?>(
        (item) {
          switch (item.type) {
            case PlaylistItemType.normal:
              return (item as PlaylistItemTrack).info.track;
            case PlaylistItemType.dummy:
            case PlaylistItemType.album:
              return null;
          }
        },
      )
      .where((e) => e != null)
      .map((e) => e!)
      .toList();

  String? firstAvailableCover() {
    for (final item in playlist.items) {
      if (item.type == PlaylistItemType.normal) {
        return (item as PlaylistItemTrack).info.track.albumId;
      } else if (item.type == PlaylistItemType.album) {
        return (item as PlaylistItemAlbum).info;
      } else {
        continue;
      }
    }

    return null;
  }
}
