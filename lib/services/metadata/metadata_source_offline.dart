import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';

class OfflineMetadataSource extends MetadataSource {
  @override
  Future<List<String>> getAlbumsByTag(String tag) async {
    return [];
  }

  @override
  Future<Map<String, Album>> getAlbums(List<String> albums) async {
    return {};
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    return {};
  }

  @override
  Future<void> prepare() async {}
}
