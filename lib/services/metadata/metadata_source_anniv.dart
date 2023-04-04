import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnivMetadataSource extends MetadataSource with CachedMetadataStore {
  final AnnivService anniv;

  Ref get ref => anniv.ref;

  AnnivMetadataSource(this.anniv);

  @override
  Future<void> prepare() async {}

  @override
  Future<Map<String, Album>> getAlbumsDetail(final List<String> albums) async {
    final client = anniv.client;

    if (ref.read(isOnlineProvider) && client != null) {
      return await client.getAlbumMetadata(albums);
    } else {
      return {};
    }
  }

  @override
  Future<Set<String>> getAlbumsByTag(final String tag) async {
    final client = anniv.client;

    if (ref.read(isOnlineProvider) && client != null) {
      final albums = await client.getAlbumsByTag(tag);
      for (final album in albums) {
        persist(album);
      }
      return albums.map((final e) => e.albumId).toSet();
    } else {
      return {};
    }
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    final client = anniv.client;

    if (ref.read(isOnlineProvider) && client != null) {
      final result =
          await Future.wait([client.getTags(), client.getTagsRelationship()]);
      final tags = result[0] as List<TagInfo>;
      final childrenMap = result[1] as Map<String, List<String>>;
      return Map.fromEntries(tags.map(
        (final e) => MapEntry(
          e.name,
          TagEntry(
            name: e.name,
            type: e.type,
            children: childrenMap[e.name] ?? [],
          ),
        ),
      ));
    } else {
      return {};
    }
  }
}
