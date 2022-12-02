import 'package:annix/global.dart';
import 'package:annix/services/annil/audio_source.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:provider/provider.dart';

class Playlist {
  final PlaylistData intro;
  final List<AnnivPlaylistItem> items;

  const Playlist({required this.intro, required this.items});

  static Future<Playlist> load(int id) async {
    final db = Global.context.read<LocalDatabase>();
    final anniv = Global.context.read<AnnivService>();

    final intro = await (db.playlist.select()
          ..where((tbl) => tbl.id.equals(id)))
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

  List<AnnilAudioSource> getTracks({List<int>? reorder}) {
    return items
        .map<TrackInfoWithAlbum?>(
          (item) {
            if (item is AnnivPlaylistItemTrack) {
              return item.info;
            } else {
              return null;
            }
          },
        )
        .whereType<TrackInfoWithAlbum>()
        .mapIndexed(
          (index, track) => _IndexedAudioSource(
            reorder != null ? reorder[index] : index,
            AnnilAudioSource(track: track),
          ),
        )
        .sortedBy<num>((e) => e.index)
        .map((e) => e.source)
        .toList();
  }
}

class _IndexedAudioSource {
  int index;
  AnnilAudioSource source;

  _IndexedAudioSource(this.index, this.source);
}
