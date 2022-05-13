import 'dart:convert';

import 'package:annix/controllers/network_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class CombinedOnlineAnnilClient {
  final Map<String, OnlineAnnilClient> clients;
  CombinedOnlineAnnilClient(List<OnlineAnnilClient> clients)
      : this.clients = Map.fromEntries(clients.map((e) => MapEntry(e.id, e)));

  bool get isEmpty => clients.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Load clients from shared preferences
  static Future<CombinedOnlineAnnilClient> load() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    if (tokens != null) {
      final _clients = tokens
          .map((token) => OnlineAnnilClient.fromJson(jsonDecode(token)))
          .toList();
      return CombinedOnlineAnnilClient(_clients);
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

  Future<IndexedAudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
  }) {
    // TODO: add option to not use mobile network
    final list = clients.values.toList();
    list.sort((a, b) => b.priority - a.priority);
    for (final client in list) {
      if (client.albums.contains(albumId)) {
        return AnnilAudioSource.create(
          annil: client,
          albumId: albumId,
          discId: discId,
          trackId: trackId,
          // TODO: select quality
          preferBitrate: PreferQuality.Medium,
        );
      }
    }

    throw new UnsupportedError("No annil client found for album $albumId");
  }

  Widget? cover({
    required String albumId,
    int? discId,
    BoxFit? fit,
    double? scale,
    String? tag,
  }) {
    final list = clients.values.toList();
    list.sort((a, b) => b.priority - a.priority);
    for (final client in list) {
      if (client.albums.contains(albumId)) {
        return CoverImage(
          albumId: albumId,
          discId: discId,
          remoteUrl: client.getCoverUrl(albumId: albumId, discId: discId),
          fit: fit ?? BoxFit.scaleDown,
          filterQuality: FilterQuality.medium,
          tag: tag,
        );
      }
    }
    return null;
  }
}

class AnnilController extends GetxController {
  final Rx<CombinedOnlineAnnilClient> clients;
  final RxList<String> albums = <String>[].obs;
  bool get hasClient => clients.value.isNotEmpty;

  NetworkController _network = Get.find();

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

  Future<IndexedAudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
  }) {
    if (!_network.isOnline.value) {
      return AnnilAudioSource.local(
        albumId: albumId,
        discId: discId,
        trackId: trackId,
      );
    } else {
      return clients.value.getAudio(
        albumId: albumId,
        discId: discId,
        trackId: trackId,
      );
    }
  }

  Widget cover({
    required String albumId,
    int? discId,
    BoxFit? fit,
    double? scale,
    String? tag,
  }) {
    var cover;
    if (_network.isOnline.value) {
      cover = clients.value.cover(
        albumId: albumId,
        discId: discId,
      );
    }

    // offline, load cached cover
    cover ??= cover = CoverImage(
      albumId: albumId,
      discId: discId,
      fit: fit ?? BoxFit.scaleDown,
      filterQuality: FilterQuality.medium,
      tag: tag,
    );

    return cover;
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
