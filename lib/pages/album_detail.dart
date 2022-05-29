import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/third_party/marquee_widget/marquee_widget.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String tag;
  final Album album;

  const AlbumDetailScreen({Key? key, required this.album, required this.tag})
      : super(key: key);

  List<Widget> getAlbumTracks(BuildContext context, AnnilController annil) {
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
              title: Text('${track.title}', overflow: TextOverflow.ellipsis),
              subtitle: ArtistText(track.artist),
              minLeadingWidth: 16,
              enabled: annil.isAvailable(
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
    return list;
  }

  void playAlbum(AnnilController annil, bool shuffle) async {
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
        if (annil.isAvailable(
          albumId: song.albumId,
          discId: song.discId,
          trackId: song.trackId,
        )) {
          songs.add(song);
        }
      });
      discId++;
    });

    if (shuffle) {
      songs.shuffle();
    }

    final PlayingController playing = Get.find();

    await playing.setPlayingQueue(
      await Future.wait(
        songs.map<Future<IndexedAudioSource>>(
          (s) => annil.getAudio(
            albumId: s.albumId,
            discId: s.discId,
            trackId: s.trackId,
          ),
        ),
      ),
    );
  }

  Widget _albumIntro(BuildContext context) {
    final AnnilController annil = Get.find();

    return Container(
      height: 150,
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cover
          Container(
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 8,
              child: AspectRatio(
                aspectRatio: 1,
                child: annil.cover(
                  albumId: album.albumId,
                  fit: BoxFit.fitWidth,
                  tag: tag,
                ),
              ),
            ),
          ),
          // intro text
          Flexible(
            child: Container(
              padding: EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    album.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium,
                    textScaleFactor: 1.2,
                    minFontSize: context.textTheme.titleSmall!.fontSize!,
                  ),
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();
    final AnnilController annil = Get.find();
    var tracks = getAlbumTracks(context, annil);

    return Scaffold(
      appBar: AppBar(
        title: Text("Album"),
        actions: [
          IconButton(
            icon: Icon(Icons.search_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _albumIntro(context),
          Expanded(
            child: ListView(
              children: tracks,
            ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onLongPress: () {
          settings.shufflePlayButton.value = !settings.shufflePlayButton.value;
        },
        child: Obx(() {
          return FloatingActionButton(
            child: Icon(
              settings.shufflePlayButton.value
                  ? Icons.shuffle
                  : Icons.play_arrow,
            ),
            onPressed: () => playAlbum(annil, settings.shufflePlayButton.value),
          );
        }),
      ),
    );
  }
}
