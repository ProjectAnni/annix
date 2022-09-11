import 'package:annix/global.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';
import 'package:annix/services/network/network.dart';
import 'package:provider/provider.dart';

class AnnivMetadataSource extends MetadataSource with CachedMetadataStore {
  AnnivMetadataSource();

  @override
  Future<void> prepare() async {}

  @override
  Future<Map<String, Album>> getAlbumsDetail(List<String> albums) async {
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);
    final client = anniv.client;

    if (NetworkService.isOnline && client != null) {
      return await client.getAlbumMetadata(albums);
    } else {
      return {};
    }
  }

  @override
  Future<List<String>> getAlbumsByTag(String tag) async {
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);
    final client = anniv.client;

    if (NetworkService.isOnline && client != null) {
      final albums = await client.getAlbumsByTag(tag);
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
    final anniv = Provider.of<AnnivService>(Global.context, listen: false);
    final client = anniv.client;

    if (NetworkService.isOnline && client != null) {
      final result =
          await Future.wait([client.getTags(), client.getTagsRelationship()]);
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
    } else {
      return {};
    }
  }
}
