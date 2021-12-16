import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:annix/services/anniv.dart';

class AnnivMetadataSource extends BaseMetadataSource {
  AnnivClient anniv;

  AnnivMetadataSource({required this.anniv});

  @override
  Future<void> prepare() async {}

  @override
  Future<Album?> getAlbumDetail({required String albumId}) async {
    final result = await anniv.getAlbumMetadata([albumId]);
    if (result.isEmpty) {
      return null;
    } else {
      return result.values.first;
    }
  }

  @override
  bool get needPersist => true;
}
