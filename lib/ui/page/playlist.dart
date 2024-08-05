import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv_model.dart' hide Playlist;
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/play_shuffle_button_group.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_playlist_page.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum _PlaylistAction {
  edit,
  delete,
}

final playlistFamily =
    FutureProvider.family<Playlist, PlaylistInfo>((ref, playlistInfo) {
  final db = ref.read(localDatabaseProvider);
  final anniv = ref.read(annivProvider);
  return Playlist.loadRemote(info: playlistInfo, db: db, anniv: anniv);
});

class LoadingPlaylistPage extends ConsumerWidget {
  final PlaylistInfo playlistInfo;

  const LoadingPlaylistPage({super.key, required this.playlistInfo});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final playlist = ref.watch(playlistFamily(playlistInfo));

    return playlist.when(
      data: (playlist) => PlaylistPage(playlist: playlist),
      error: (a, b) => const Text('Error'),
      loading: () => const ShimmerPlaylistPage(),
    );
  }
}

class PlaylistPage extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistPage({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  /// Flag to control whether playlist is in edit mode
  bool _editMode = false;

  /// Reorder map, generated
  List<int>? _reorder;

  @override
  void initState() {
    super.initState();

    // TODO: move to route delegate
    final coverIdentifier = this.coverIdentifier();
    if (coverIdentifier != null) {
      final cover = DiscIdentifier.fromIdentifier(coverIdentifier);
      ref.read(themeProvider).pushTemporaryTheme(cover.albumId);
    }
  }

  String? coverIdentifier() {
    String? coverIdentifier = widget.playlist.intro.cover;

    if (coverIdentifier == null ||
        coverIdentifier == '' ||
        coverIdentifier.startsWith('/')) {
      coverIdentifier = widget.playlist.firstAvailableCover();
    }
    return coverIdentifier;
  }

  Widget? _cover({final bool card = true}) {
    String? oldCoverIdentifier = widget.playlist.intro.cover;

    if (oldCoverIdentifier == null ||
        oldCoverIdentifier == '' ||
        oldCoverIdentifier.startsWith('/')) {
      oldCoverIdentifier = widget.playlist.firstAvailableCover();

      final anniv = ref.read(annivProvider);
      if (oldCoverIdentifier != null &&
          widget.playlist.intro.remoteId != null &&
          anniv.client != null) {
        anniv.client?.updatePlaylistInfo(
          playlistId: widget.playlist.intro.remoteId!,
          info: PatchedPlaylistInfo(
            // FIXME: do not use disc id
            cover: DiscIdentifier(albumId: oldCoverIdentifier, discId: 1),
          ),
        );
      }
    }

    final coverIdentifier = this.coverIdentifier();

    if (coverIdentifier == null) {
      return null;
    } else {
      final cover = DiscIdentifier.fromIdentifier(coverIdentifier);
      final child = MusicCover.fromAlbum(
        albumId: cover.albumId,
        discId: cover.discId,
      );
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

  void _onPlay({final int index = 0, final bool shuffle = false}) {
    final player = ref.read(playbackProvider);
    playFullList(
      player: player,
      tracks: widget.playlist.getTracks(reorder: _reorder),
      initialIndex: index,
      shuffle: shuffle,
    );
  }

  Widget _buildTrackList() {
    final annil = ref.read(annilProvider);

    return SliverReorderableList(
      onReorder: (final int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }

          final tmp = _reorder![oldIndex];
          if (oldIndex < newIndex) {
            // moving down
            for (int i = oldIndex; i < newIndex; i++) {
              _reorder![i] = _reorder![i + 1];
            }
            _reorder![newIndex] = tmp;
          } else if (oldIndex > newIndex) {
            // moving up
            for (int i = oldIndex; i > newIndex; i--) {
              _reorder![i] = _reorder![i - 1];
            }
          }
          _reorder![newIndex] = tmp;
        });
      },
      itemCount: widget.playlist.items.length,
      itemBuilder: (final context, final index) {
        final item =
            widget.playlist.items[_reorder != null ? _reorder![index] : index];
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
              _editMode
                  ? ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    )
                  : Container(
                      width: 24,
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: context.textTheme.labelLarge,
                      ),
                    ),
              const SizedBox(width: 8),
              CoverCard(
                child: MusicCover.fromAlbum(
                  albumId: item.info.id.albumId,
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
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
          enabled: annil.isTrackAvailable(item.info.id),
          onTap: () => _onPlay(index: index),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    final cover = _cover();
    final description = widget.playlist.getDescription();

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!_editMode)
            PopupMenuButton<_PlaylistAction>(
              itemBuilder: (final context) => [
                if (!_editMode)
                  PopupMenuItem(
                    value: _PlaylistAction.edit,
                    child: Text(t.playlist.edit),
                  ),
                const PopupMenuItem(
                  value: _PlaylistAction.delete,
                  child: Text('Delete'),
                ),
              ],
              onSelected: (final value) {
                switch (value) {
                  case _PlaylistAction.edit:
                    // generate reorder list on entering edit mode
                    _reorder ??= List.generate(
                      widget.playlist.items.length,
                      (final index) => index,
                    );

                    setState(() {
                      _editMode = true;
                    });
                    break;
                  case _PlaylistAction.delete:
                    // TODO: show dialog
                    break;
                }
              },
            ),
          if (_editMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // TODO: save edited result to server, keep _reorder on success, or set it to null
                setState(() {
                  _editMode = false;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: CustomScrollView(
          slivers: [
            if (context.isMobileOrPortrait && cover != null)
              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (final context, final constraints) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth / 6,
                      ),
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
                    if (context.isMobileOrPortrait)
                      CircleAvatar(
                        // FIXME: use avatar of playlist creator
                        child: _cover(card: true),
                      ),
                    if (context.isDesktopOrLandscape)
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
                            widget.playlist.intro.name,
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
                              onOpen: (final link) => launchUrlString(link.url),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: PlayShuffleButtonGroup(
                stretch: context.isMobileOrPortrait,
                onPlay: () => _onPlay(),
                onShufflePlay: () => _onPlay(shuffle: true),
              ),
            ),
            _buildTrackList(),
          ],
        ),
      ),
    );
  }
}
