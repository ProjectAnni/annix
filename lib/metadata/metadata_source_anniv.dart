import 'package:annix/controllers/network_controller.dart';
import 'package:annix/metadata/metadata_types.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/services/anniv.dart';
import 'package:get/get.dart';

class AnnivMetadataSource extends MetadataSource {
  final AnnivClient anniv;
  AnnivMetadataSource(this.anniv);

  // cache database for offline metadata
  NetworkController _network = Get.find();

  @override
  Future<void> prepare() async {}

  Future<Map<String, Album>> getAlbumsDetail(List<String> albums) async {
    if (_network.isOnline.value) {
      return await this.anniv.getAlbumMetadata(albums);
    } else {
      return Map();
    }
  }

  @override
  bool get needPersist => true;

  @override
  Future<List<String>> getAlbumsByTag(String tag) async {
    if (_network.isOnline.value) {
      final albums = await this.anniv.getAlbumsByTag(tag);
      albums.forEach((album) {
        this.persist(album);
      });
      return albums.map((e) => e.albumId).toList();
    } else {
      return [];
    }
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    final result = await Future.wait(
        [this.anniv.getTags(), this.anniv.getTagsRelationship()]);
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
