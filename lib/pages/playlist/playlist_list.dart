import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetailScreen extends PlaylistScreen {
  final AnnilController _annil = Get.find();

  final Playlist playlist;

  final Widget? pageTitle = null;
  final List<Widget>? pageActions = null;
  final RefreshCallback? refresh = null;

  PlaylistDetailScreen({required this.playlist});

  String get title => playlist.intro.name;
  Widget get cover {
    final albumId = playlist.intro.cover.albumId == ""
        ? firstAvailableCover()
        : playlist.intro.cover.albumId;
    if (albumId == null) {
      return DummyMusicCover();
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

  Widget get body {
    return ListView.separated(
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
          enabled: _annil.isAvailable(
            albumId: track.info.track.albumId,
            discId: track.info.track.discId,
            trackId: track.info.track.trackId,
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(height: 8),
    );
  }

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
