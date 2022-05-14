import 'package:annix/controllers/network_controller.dart';
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
}
