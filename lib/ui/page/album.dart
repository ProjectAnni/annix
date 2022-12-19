import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/utils/display_or_lazy_screen.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:annix/global.dart';
import 'package:annix/i18n/strings.g.dart';

class LazyAlbumPage extends StatelessWidget {
  final String albumId;

  const LazyAlbumPage({required this.albumId, super.key});

  @override
  Widget build(BuildContext context) {
    return DisplayOrLazyLoadScreen<Album>(
      future: context
          .read<MetadataService>()
          .getAlbum(albumId: albumId)
          .then((album) {
        if (album == null) throw 'Album not found';
        return album;
      }),
      builder: (album) => AlbumPage(album: album),
    );
  }
}

class AlbumPage extends StatelessWidget {
  final Album album;

  const AlbumPage({super.key, required this.album});

  void _onPlay(BuildContext context, {int index = 0, bool shuffle = false}) {
    final player = context.read<PlaybackService>();
    playFullList(
      player: player,
      tracks: album.getTracks(),
      initialIndex: index,
      shuffle: shuffle,
    );
  }

  Widget _playButtons(BuildContext context, {bool stretch = false}) {
    return LayoutBuilder(builder: (context, constraints) {
      double? maxWidth;
      if (stretch && constraints.maxWidth != double.infinity) {
        maxWidth = constraints.maxWidth / 2.2;
      }

      return ButtonBar(
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
        alignment: stretch ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text(t.playback.play_all),
              onPressed: () => _onPlay(context),
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: FilledButton.icon(
              icon: const Icon(Icons.shuffle),
              label: Text(t.playback.shuffle),
              onPressed: () => _onPlay(context, shuffle: true),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTrackList(BuildContext context) {
    final List<Widget> list = [];

    bool needDiscId = false;
    if (album.discs.length > 1) {
      needDiscId = true;
    }

    int trackIndex = 0;
    int discId = 1;
    for (final disc in album.discs) {
      if (needDiscId) {
        list.add(DiscTitleListTile(title: disc.title, index: discId));
      }

      list.addAll(disc.tracks
          .map((track) => TrackListTile(track: track, index: trackIndex++)));
      discId++;
    }

    return SliverList(delegate: SliverChildListDelegate(list));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FavoriteAlbumButton(albumId: album.albumId),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            if (!Global.isDesktop)
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth / 6),
                      child: MusicCover(albumId: album.albumId),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!Global.isDesktop)
                      CircleAvatar(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: context.colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: MusicCover(albumId: album.albumId),
                        ),
                      ),
                    if (Global.isDesktop)
                      SizedBox(
                        height: 240,
                        child: MusicCover(albumId: album.albumId),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: context.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          ArtistText(
                            album.artist,
                            style: context.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _playButtons(context, stretch: !Global.isDesktop),
            ),
            _buildTrackList(context),
          ],
        ),
      ),
    );
  }
}

class DiscTitleListTile extends StatelessWidget {
  final String title;
  final int index;

  const DiscTitleListTile(
      {super.key, required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: context.colorScheme.primary,
      iconColor: context.colorScheme.primary,
      leading: const Icon(Icons.album_outlined),
      title: SelectableText(title, maxLines: 1),
      trailing: Text('$index'),
      minLeadingWidth: 12,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}

class TrackListTile extends StatelessWidget {
  final int index;
  final Track track;

  const TrackListTile({super.key, required this.track, required this.index});

  @override
  Widget build(BuildContext context) {
    final annil = context.read<AnnilService>();

    return ListTile(
      leading: Text('${track.id.trackId}'),
      // dense: true,
      title: Text(
        track.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: ArtistText(track.artist),
      enabled: annil.isTrackAvailable(track.id),
      minLeadingWidth: 12,
      onTap: () async {
        final player = context.read<PlaybackService>();
        final tracks = track.disc.album.getTracks();
        playFullList(
          player: player,
          tracks: tracks,
          initialIndex: index,
        );
      },
      // selected: TODO: indicate playing track,
    );
  }
}
