import 'package:annix/global.dart';
import 'package:annix/services/annil/cache.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PlayingMoreMenu extends StatelessWidget {
  final Track track;

  const PlayingMoreMenu({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final delegate = AnnixRouterDelegate.of(context);

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.music_note_rounded),
          minLeadingWidth: 0,
          title: Text(
            track.title,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.album_outlined),
          minLeadingWidth: 0,
          title: Text(
            track.disc.album.fullTitle,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          onTap: () async {
            // hide dialog
            await delegate.popRoute();
            // hide playing page
            Global.mobileWeSlideController.hide();
            delegate.to(name: "/album", arguments: track.disc.album);
          },
        ),
        ListTile(
          leading: const Icon(Icons.person_rounded),
          minLeadingWidth: 0,
          title: ArtistText(track.artist),
        ),
        const Divider(),
        // ListTile(
        //   leading: const Icon(Icons.share),
        //   title: const Text("Share"),
        //   onTap: () {
        //     Share.share("Test");
        //   },
        // ),
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text("Share File"),
          onTap: () {
            final id = track.id;
            Share.shareFiles(
              [
                getAudioCachePath(
                  id.albumId,
                  id.discId,
                  id.trackId,
                )
              ],
              mimeTypes: ["audio/flac"],
            );
          },
        ),
      ],
    );
  }
}
