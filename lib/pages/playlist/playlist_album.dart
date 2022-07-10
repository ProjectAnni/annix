import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/pages/playlist/playlist.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumDetailScreen extends PlaylistScreen {
  final AnnilController _annil = Get.find();

  final Album album;

  AlbumDetailScreen({required this.album, Key? key})
      : super(key: key, pageTitle: Text(I18n.ALBUMS.tr));

  String get title => album.title;
  Widget get cover => _annil.cover(albumId: album.albumId);

  @override
  List<Widget> get intro => [
        Text(album.date.toString()),
        // TODO: Add some action buttons
        // Row(
        //   children: [
        //     InkWell(
        //       child: Container(
        //         child: const Icon(
        //           Icons.add_box_outlined,
        //           size: 32.0,
        //         ),
        //       ),
        //       onTap: () {},
        //     ),
        //   ],
        // ),
      ];

  Widget get body => getAlbumTracks();

  List<TrackIdentifier> get tracks {
    List<TrackIdentifier> songs = [];

    var discId = 1;
    album.discs.forEach((disc) {
      var trackId = 1;
      disc.tracks.forEach((element) {
        // check if available
        final song = TrackIdentifier(
          albumId: album.albumId,
          discId: discId,
          trackId: trackId++,
        );
        if (_annil.isAvailable(
          albumId: song.albumId,
          discId: song.discId,
          trackId: song.trackId,
        )) {
          songs.add(song);
        }
      });
      discId++;
    });

    return songs;
  }

  ListView getAlbumTracks() {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (album.discs.length > 1) {
      needDiscId = true;
    }

    var discId = 1;
    album.discs.forEach((disc) {
      if (needDiscId) {
        var discTitle = 'Disc $discId';
        if (disc.title != "") {
          discTitle += ' - ${disc.title}';
        }
        list.add(ListTile(title: Marquee(child: Text(discTitle))));
      }

      var trackId = 1;
      list.addAll(
        disc.tracks.map(
          (track) {
            final trackIndex = trackId;
            trackId++;
            // TODO: indicate playing track
            return ListTile(
              leading: Text("$trackIndex"),
              minLeadingWidth: 16,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text('${track.title}', overflow: TextOverflow.ellipsis),
              subtitle: ArtistText(track.artist),
              enabled: _annil.isAvailable(
                albumId: album.albumId,
                discId: discId,
                trackId: trackIndex,
              ),
            );
          },
        ),
      );
      discId++;
    });

    return ListView.separated(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return list[index];
      },
      separatorBuilder: (context, index) => Divider(
        height: 8,
      ),
    );
  }
}
