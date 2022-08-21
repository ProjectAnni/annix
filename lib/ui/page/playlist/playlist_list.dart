import 'dart:convert';

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
        ...(playlist.description != null ? [Text(playlist.description!)] : []),
      ];

  @override
  Widget get body {
    final annil =
        Provider.of<CombinedOnlineAnnilClient>(Global.context, listen: false);

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final track = items[index];
        return ListTile(
          leading: Text("${index + 1}"),
          minLeadingWidth: 16,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text('${track.info.title}', overflow: TextOverflow.ellipsis),
          subtitle: track.description != null && track.description!.isNotEmpty
              ? ArtistText(track.description!)
              : null,
          enabled: annil.isAvailable(track.info.track),
        );
      },
    );
  }

  @override
  List<TrackIdentifier> get tracks => items
      .map<TrackIdentifier?>(
        (item) {
          switch (item.type) {
            case PlaylistItemType.normal:
              return TrackInfoWithAlbum.fromJson(jsonDecode(item.info)).track;
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
    for (final item in items) {
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
