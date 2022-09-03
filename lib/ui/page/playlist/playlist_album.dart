import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/ui/page/playlist/playlist.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class LazyLoadAlbumDetailScreen extends StatelessWidget {
  final String albumId;

  const LazyLoadAlbumDetailScreen({Key? key, required this.albumId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final metadata = Provider.of<MetadataService>(context, listen: false);
    return FutureProvider<Album?>.value(
      value: metadata.getAlbum(albumId: albumId),
      initialData: null,
      builder: (context, child) {
        final album = context.watch<Album?>();
        if (album == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return AlbumDetailScreen(album: album);
        }
      },
    );
  }
}

class AlbumDetailScreen extends PlaylistScreen {
  final Album album;

  @override
  Widget? get pageTitle => Text(I18n.ALBUMS.tr);
  @override
  final List<Widget>? pageActions = null;
  @override
  final RefreshCallback? refresh = null;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  String get title => album.fullTitle;

  @override
  Widget get cover => MusicCover(albumId: album.albumId, card: true);

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

  @override
  Widget get body => getAlbumTracks();

  @override
  List<AnnilAudioSource> get tracks {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);

    List<AnnilAudioSource> songs = [];

    for (final disc in album.discs) {
      for (final track in disc.tracks) {
        // check if available
        final trackId = track.id;
        if (annil.isAvailable(trackId)) {
          songs.add(
              AnnilAudioSource(track: TrackInfoWithAlbum.fromTrack(track)));
        }
      }
    }

    return songs;
  }

  ListView getAlbumTracks() {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);
    final List<Widget> list = [];

    bool needDiscId = false;
    if (album.discs.length > 1) {
      needDiscId = true;
    }

    var totalTrackId = 0;

    var discId = 1;
    for (final disc in album.discs) {
      if (needDiscId) {
        var discTitle = 'Disc $discId';
        if (disc.title != "") {
          discTitle += ' - ${disc.title}';
        }
        list.add(ListTile(title: Text(discTitle)));
      }

      var trackId = 1;
      list.addAll(
        disc.tracks.map(
          (track) {
            final trackIndex = trackId;
            trackId++;

            final totalTrackIndex = totalTrackId;
            totalTrackId++;
            return ListTile(
              leading: Text("$trackIndex"),
              minLeadingWidth: 16,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(track.title, overflow: TextOverflow.ellipsis),
              subtitle: ArtistText(track.artist),
              enabled: annil.isAvailable(
                TrackIdentifier(
                  albumId: album.albumId,
                  discId: discId,
                  trackId: trackIndex,
                ),
              ),
              onTap: () {
                playFullList(Global.context, initialIndex: totalTrackIndex);
              },
              // selected: TODO: indicate playing track,
            );
          },
        ),
      );
      discId++;
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return list[index];
      },
    );
  }

  @override
  Future<void>? get loading => null;
}
