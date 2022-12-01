import 'package:annix/global.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart' hide Playlist;
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/page/playlist/playlist_base.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PlaylistPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistPage({super.key, required this.playlist});

  Widget? _cover(BuildContext context, {bool card = true}) {
    String? coverIdentifier = playlist.intro.cover;
    if (coverIdentifier == null ||
        coverIdentifier == '' ||
        coverIdentifier.startsWith('/')) {
      coverIdentifier = playlist.firstAvailableCover();

      final AnnivService anniv = context.read();
      if (coverIdentifier != null &&
          playlist.intro.remoteId != null &&
          anniv.client != null) {
        anniv.client?.updatePlaylistInfo(
          playlistId: playlist.intro.remoteId!,
          info: PatchedPlaylistInfo(
            // FIXME: do not use disc id
            cover: DiscIdentifier(albumId: coverIdentifier, discId: 1),
          ),
        );
      }
    }

    if (coverIdentifier == null) {
      return null;
    } else {
      final cover = DiscIdentifier.fromIdentifier(coverIdentifier);
      final child = MusicCover(albumId: cover.albumId, discId: cover.discId);
      if (!card) return child;

      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: context.colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        clipBehavior: Clip.hardEdge,
        child: child,
      );
    }
  }

  void _onPlay(BuildContext context, {int index = 0, bool shuffle = false}) {
    final player = context.read<PlaybackService>();
    playFullList(
      player: player,
      tracks: playlist.getTracks(),
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
    final annil = context.read<AnnilService>();

    return SliverReorderableList(
      onReorder: (int oldIndex, int newIndex) {},
      itemCount: playlist.items.length,
      itemBuilder: (context, index) {
        final item = playlist.items[index];
        if (item is! AnnivPlaylistItemTrack) {
          return ListTile(
            title: const Text('TODO'),
            subtitle: Text(item.description ?? ''),
          );
        }

        final useThreeLine =
            item.description != null && item.description!.isNotEmpty;
        return ListTile(
          key: ValueKey(item),
          isThreeLine: useThreeLine,
          contentPadding: EdgeInsets.zero,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: index,
                enabled: false,
                child: const Icon(Icons.drag_handle),
              ),
              const SizedBox(width: 8),
              CoverCard(
                child: MusicCover(
                  albumId: item.info.id.albumId,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          title: Text(
            item.info.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArtistText(item.info.artist),
              if (useThreeLine)
                Text(
                  item.description!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                )
            ],
          ),
          trailing: const Icon(Icons.more_vert),
          enabled: annil.isAvailable(item.info.id),
          onTap: () => _onPlay(context, index: index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cover = _cover(context);
    final description = playlist.getDescription();

    return Scaffold(
      appBar: AppBar(actions: const [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: null,
        ),
      ]),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            if (!Global.isDesktop && cover != null)
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth / 6),
                      child: cover,
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
                        // FIXME: use user avatar
                        child: _cover(context, card: true),
                      ),
                    if (Global.isDesktop)
                      SizedBox(
                        height: 240,
                        child: cover!,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.intro.name,
                            style: context.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (description != null)
                            Linkify(
                              text: description,
                              style: context.textTheme.bodyLarge,
                              linkStyle: context.textTheme.bodyLarge
                                  ?.copyWith(color: Colors.blueAccent),
                              options: const LinkifyOptions(humanize: false),
                              onOpen: (link) => launchUrlString(link.url),
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
