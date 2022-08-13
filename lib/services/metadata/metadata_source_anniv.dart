import 'package:annix/services/metadata/metadata_types.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:annix/services/anniv.dart';
import 'package:annix/services/network.dart';

class AnnivMetadataSource extends MetadataSource {
  final AnnivClient anniv;
  AnnivMetadataSource(this.anniv);

  // cache database for offline metadata

  @override
  Future<void> prepare() async {}

  @override
  Future<Map<String, Album>> getAlbumsDetail(List<String> albums) async {
    if (NetworkService.isOnline) {
      return await anniv.getAlbumMetadata(albums);
    } else {
      return {};
    }
  }

  @override
  bool get needPersist => true;

  @override
  Future<List<String>> getAlbumsByTag(String tag) async {
    if (NetworkService.isOnline) {
      final albums = await anniv.getAlbumsByTag(tag);
      for (final album in albums) {
        persist(album);
      }
      return albums.map((e) => e.albumId).toList();
    } else {
      return [];
    }
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    final result =
        await Future.wait([anniv.getTags(), anniv.getTagsRelationship()]);
    final tags = result[0] as List<TagInfo>;
    final childrenMap = result[1] as Map<String, List<String>>;
    return Map.fromEntries(tags.map(
      (e) => MapEntry(
        e.name,
        TagEntry(
          name: e.name,
          type: e.type,
          children: childrenMap[e.name] ?? [],
        ),
      ),
    ));
  }
}
