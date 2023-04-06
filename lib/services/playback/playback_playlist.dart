import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

class Playlist {
  final PlaylistData intro;
  final List<AnnivPlaylistItem> items;

  const Playlist({required this.intro, required this.items});

  static Future<Playlist> load({
    required final int id,
    required final LocalDatabase db,
    required final AnnivService anniv,
  }) async {
    final intro = await (db.playlist.select()
          ..where((final tbl) => tbl.id.equals(id)))
        .getSingle();

    final items = await anniv.getPlaylistItems(intro);
    if (items == null) {
      throw Exception('Failed to load playlist items');
    }
    return Playlist(intro: intro, items: items);
  }

  String? firstAvailableCover() {
    for (final item in items) {
      if (item is AnnivPlaylistItemTrack) {
        return item.info.id.albumId;
      } else if (item is AnnivPlaylistItemAlbum) {
        return item.albumId;
      } else {
        continue;
      }
    }

    return null;
  }

  String? getDescription() {
    if (intro.description != null && intro.description!.isNotEmpty) {
      return intro.description;
    }
    return null;
  }

  List<AnnilAudioSource> getTracks({final List<int>? reorder}) {
    final tracks = items
        .map<TrackInfoWithAlbum?>(
          (final item) {
            if (item is AnnivPlaylistItemTrack) {
              return item.info;
            } else {
              return null;
            }
          },
        )
        .whereType<TrackInfoWithAlbum>()
        .toList();

    return tracks.mapIndexed((final i, final element) {
      final index = reorder != null ? reorder[i] : i;
      return AnnilAudioSource(track: tracks[index]);
    }).toList();
  }
}
