import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil/client.dart';
import 'package:annix/services/global.dart';
import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart';

class AnnilController extends GetxController {
  final Rx<CombinedOnlineAnnilClient> clients;
  final RxList<String> albums = <String>[].obs;
  bool get hasClient => clients.value.isNotEmpty;

  static Future<AnnilController> init() async {
    return AnnilController._(await CombinedOnlineAnnilClient.loadFromLocal());
  }

  AnnilController._(CombinedOnlineAnnilClient clients) : clients = clients.obs;

  @override
  void onInit() {
    super.onInit();
    Global.network.addListener(onNetworkChange);
  }

  @override
  void onClose() {
    super.onClose();
    Global.network.removeListener(onNetworkChange);
  }

  void onNetworkChange() {
    reloadClients();
  }

  /// Sync remote annil tokens with local ones
  void syncWithRemote(List<AnnilToken> remoteList) {
    clients.value.sync(remoteList);
    clients.refresh();
  }

  /// Refresh all annil servers
  Future<void> reloadClients() async {
    if (Global.network.isOnline) {
      var newAlbums =
          (await Future.wait(clients.value.clients.values.map((client) async {
        try {
          return await client.getAlbums();
        } catch (e) {
          FLog.error(
            text: "Failed to refresh annil client ${client.name}",
            exception: e,
          );
          // TODO: use local copy
          return <String>[];
        }
      })))
              .expand((e) => e)
              .toSet()
              .toList();
      albums.replaceRange(0, albums.length, newAlbums);
      clients.value.saveToLocal();
    } else {
      var newAlbums = await OfflineAnnilClient().getAlbums();
      albums.replaceRange(0, albums.length, newAlbums);
    }
    albums.refresh();
  }

  bool isAvailable({
    required String albumId,
    required int discId,
    required int trackId,
  }) {
    return OfflineAnnilClient()
            .isAvailable(albumId: albumId, discId: discId, trackId: trackId) ||
        (Global.network.isOnline && albums.contains(albumId));
  }
}
