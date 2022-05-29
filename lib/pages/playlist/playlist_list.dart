import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistDetailScreen extends PlaylistScreen {
  final AnnilController _annil = Get.find();

  final Playlist playlist;

  PlaylistDetailScreen({required this.playlist, Key? key}) : super(key: key);

  String get title => playlist.intro.name;
  Widget get cover => _annil.cover(
        albumId: playlist.intro.cover.albumId == ""
            ? firstAvailableCover()
            : playlist.intro.cover.albumId,
      );

  @override
  List<Widget> get intro => [
        // description
        ...(playlist.intro.description != null
            ? [Text(playlist.intro.description!)]
            : []),
      ];

  Widget get body => ListView(
        children: playlist.items.map(
          (item) {
            final track = item as PlaylistItemTrack;
            return ListTile(
              title:
                  Text('${track.info.title}', overflow: TextOverflow.ellipsis),
              subtitle: track.description != null
                  ? ArtistText(track.description!)
                  : null,
              minLeadingWidth: 16,
              enabled: _annil.isAvailable(
                albumId: track.info.track.albumId,
                discId: track.info.track.discId,
                trackId: track.info.track.trackId,
              ),
            );
          },
        ).toList(),
      );

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
