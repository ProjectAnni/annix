import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart' hide PlaylistItem;
import 'package:annix/ui/page/playlist/playlist.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistDetailScreen extends PlaylistScreen {
  final int id;

  @override
  late final Future<void> loading;
  late final PlaylistData playlist;
  late final List<PlaylistItem> items;

  @override
  final Widget? pageTitle = null;
  @override
  final List<Widget>? pageActions = null;
  @override
  final RefreshCallback? refresh = null;

  PlaylistDetailScreen({super.key, required this.id}) {
    loading = (() async {
      final db = Provider.of<LocalDatabase>(Global.context, listen: false);
      final anniv = Provider.of<AnnivService>(Global.context, listen: false);
      playlist = await (db.playlist.select()..where((tbl) => tbl.id.equals(id)))
          .getSingle();

      final items = await anniv.getPlaylistItems(playlist);
      if (items == null) {
        throw Exception('Failed to load playlist items');
      }
      this.items = items;
    })();
  }

  @override
  String get title => playlist.name;

  @override
  Widget get cover {
    String? coverIdentifier = playlist.cover;
    if (coverIdentifier == null ||
        coverIdentifier == "" ||
        coverIdentifier.startsWith("/")) {
      coverIdentifier = firstAvailableCover();

      // TODO: update cover
      final AnnivService anniv = Global.context.read();
      if (coverIdentifier != null &&
          playlist.remoteId != null &&
          anniv.client != null) {
        // TODO: update information in database
        anniv.client?.updatePlaylistInfo(
          playlistId: playlist.remoteId!,
          info: PatchedPlaylistInfo(
            // FIXME: do not use disc id
            cover: DiscIdentifier(albumId: coverIdentifier, discId: 1),
          ),
        );
      }
    }

    if (coverIdentifier == null) {
      return const DummyMusicCover();
    } else {
      final cover = DiscIdentifier.fromIdentifier(coverIdentifier);
      return MusicCover(albumId: cover.albumId, discId: cover.discId);
    }
  }

  @override
  List<Widget> get intro => [
        // description
        ...(playlist.description != null
            ? [
                Text(
                  playlist.description!,
                  maxLines: 2,
                )
              ]
            : []),
      ];

  @override
  Widget get body {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final track = items[index];
        if (track is! PlaylistItemTrack) {
          return ListTile(
            title: const Text("TODO"),
            subtitle: Text(track.description ?? ''),
          );
        }

        return ListTile(
          leading: Text("${index + 1}"),
          minLeadingWidth: 16,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(track.info.title, overflow: TextOverflow.ellipsis),
          subtitle: track.description != null && track.description!.isNotEmpty
              ? ArtistText(track.description!)
              : null,
          enabled: annil.isAvailable(track.info.id),
          onTap: () {
            super.playFullList(context, initialIndex: index);
          },
        );
      },
    );
  }

  @override
  List<AnnilAudioSource> get tracks => items
      .map<AnnilAudioSource?>(
        (item) {
          if (item is PlaylistItemTrack) {
            return AnnilAudioSource(track: item.info);
          } else {
            return null;
          }
        },
      )
      .where((e) => e != null)
      .map((e) => e!)
      .toList();

  String? firstAvailableCover() {
    for (final item in items) {
      if (item is PlaylistItemTrack) {
        return item.info.id.albumId;
      } else if (item is PlaylistItemAlbum) {
        return item.albumId;
      } else {
        continue;
      }
    }

    return null;
  }
}
