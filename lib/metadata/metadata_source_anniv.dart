import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/services/global.dart';

class AnnivMetadataSource extends BaseMetadataSource {
  @override
  Future<void> prepare() async {}

  @override
  Future<Album?> getAlbumDetail({required String albumId}) async {
    final result = await Global.anniv?.getAlbumMetadata([albumId]);
    if (result == null || result.isEmpty) {
      return null;
    } else {
      return result.values.first;
    }
  }

  @override
  bool get needPersist => true;
}
