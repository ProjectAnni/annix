import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/offline_controller.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/metadata/metadata_source.dart';
import 'package:get/get.dart';

class AnnivMetadataSource extends BaseMetadataSource {
  final AnnivClient anniv;
  AnnivMetadataSource(this.anniv);

  // cache database for offline metadata
  NetworkController _network = Get.find();

  @override
  Future<void> prepare() async {}

  @override
  Future<Album?> getAlbumDetail({required String albumId}) async {
    if (_network.isOnline.value) {
      final result = await this.anniv.getAlbumMetadata([albumId]);
      if (result.isEmpty) {
        return null;
      } else {
        final album = result[albumId];
        return album;
      }
    } else {
      return null;
    }
  }

  @override
  bool get needPersist => true;
}
