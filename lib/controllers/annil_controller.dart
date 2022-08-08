import 'dart:convert';

import 'package:annix/controllers/network_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:f_logs/f_logs.dart';
import 'package:get/get.dart';

class CombinedOnlineAnnilClient {
  final Map<String, OnlineAnnilClient> clients;
  CombinedOnlineAnnilClient(List<OnlineAnnilClient> clients)
      : clients = Map.fromEntries(clients.map((e) => MapEntry(e.id, e)));

  bool get isEmpty => clients.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Load clients from shared preferences
  static Future<CombinedOnlineAnnilClient> load() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    if (tokens != null) {
      final clients = tokens
          .map((token) => OnlineAnnilClient.fromJson(jsonDecode(token)))
          .toList();
      return CombinedOnlineAnnilClient(clients);
    } else {
      return CombinedOnlineAnnilClient([]);
    }
  }

  /// Save clients to shared preferences
  Future<void> save() async {
    final tokens =
        clients.values.map((client) => jsonEncode(client.toJson())).toList();
    await Global.preferences.setStringList("annil_clients", tokens);
  }

  /// Keep sync with new credential list
  void sync(List<AnnilToken> remoteList) {
    final remoteIds = remoteList.map((e) => e.id).toList();
    // update existing client info
    clients.removeWhere((id, client) {
      final index = remoteIds.indexOf(id);
      if (index != -1) {
        // exist both in local and remote, update client info
        final newClient = remoteList[index];
        client.name = newClient.name;
        client.url = newClient.url;
        client.token = newClient.token;
        client.priority = newClient.priority;
        remoteIds.removeAt(index);
        remoteList.removeAt(index);
      } else if (!client.local) {
        // remote client which only exist in local, remove it
        return true;
      }

      // do not remove the remaining
      return false;
    });

    // add new clients
    clients.addAll(
      Map.fromEntries(
        remoteList
            .map((e) => OnlineAnnilClient.remote(
                  id: e.id,
                  name: e.name,
                  url: e.url,
                  token: e.token,
                  priority: e.priority,
                ))
            .map((c) => MapEntry(c.id, c)),
      ),
    );
  }

  String? getAudioUrl({
    required String albumId,
    required int discId,
    required int trackId,
    required PreferQuality quality,
  }) {
    final list = clients.values.toList();
    list.sort((a, b) => b.priority - a.priority);
    for (final client in list) {
      if (client.albums.contains(albumId)) {
        return '${client.url}/$albumId/$discId/$trackId?auth=${client.token}&quality=${quality.toQualityString()}';
      }
    }

    return null;
  }

  Uri? getCoverUrl({required String albumId, int? discId}) {
    final NetworkController network = Get.find();
    if (network.isOnline.value) {
      final list = clients.values.toList();
      list.sort((a, b) => b.priority - a.priority);
      for (final client in list) {
        if (client.albums.contains(albumId)) {
          return client.getCoverUrl(albumId: albumId, discId: discId);
        }
      }
    }
    return null;
  }
}

class AnnilController extends GetxController {
  final Rx<CombinedOnlineAnnilClient> clients;
  final RxList<String> albums = <String>[].obs;
  bool get hasClient => clients.value.isNotEmpty;

  final NetworkController _network = Get.find();

  static Future<AnnilController> init() async {
    return AnnilController._(await CombinedOnlineAnnilClient.load());
  }

  AnnilController._(CombinedOnlineAnnilClient clients) : clients = clients.obs;

  @override
  void onInit() {
    super.onInit();
    this._network.isOnline.listen((isOnline) {
      this.refresh();
    });
  }

  /// Sync remote annil tokens with local ones
  void syncWithRemote(List<AnnilToken> remoteList) {
    clients.value.sync(remoteList);
    clients.refresh();
  }

  /// Refresh all annil servers
  Future<void> refresh() async {
    if (_network.isOnline.value) {
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
      albums.replaceRange(0, this.albums.length, newAlbums);
      clients.value.save();
    } else {
      var newAlbums = await OfflineAnnilClient.instance.getAlbums();
      albums.replaceRange(0, this.albums.length, newAlbums);
    }
    albums.refresh();
  }

  bool isAvailable({
    required String albumId,
    required int discId,
    required int trackId,
  }) {
    if (_network.isOnline.value) {
      return true;
    } else {
      return OfflineAnnilClient.instance
          .isAvailable(albumId: albumId, discId: discId, trackId: trackId);
    }
  }
}
