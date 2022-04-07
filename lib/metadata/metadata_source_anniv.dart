import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';

class AnnivMetadataSource extends BaseMetadataSource {
  final AnnivController anniv;
  AnnivMetadataSource(this.anniv);

  @override
  Future<void> prepare() async {}

  @override
  Future<Album?> getAlbumDetail({required String albumId}) async {
    final result = await this.anniv.getAlbumMetadata([albumId]);
    if (result.isEmpty) {
      return null;
    } else {
      return result.values.first;
    }
  }

  @override
  bool get needPersist => true;
}
