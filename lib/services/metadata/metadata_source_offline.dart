import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/metadata/metadata_source.dart';

class OfflineMetadataSource extends MetadataSource {
  @override
  Future<Set<String>> getAlbumsByTag(final String tag) async {
    return {};
  }

  @override
  Future<Map<String, Album>> getAlbums(final List<String> albums) async {
    return {};
  }

  @override
  Future<Map<String, TagEntry>> getTags() async {
    return {};
  }

  @override
  Future<void> prepare() async {}
}
