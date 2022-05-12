import 'dart:convert';

import 'package:annix/controllers/offline_controller.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AnnilController extends GetxController {
  final RxMap<String, OnlineAnnilClient> clients =
      Map<String, OnlineAnnilClient>().obs;
  final RxList<String> albums = <String>[].obs;
  bool get hasClient => clients.isNotEmpty;

  NetworkController _network = Get.find();

  /// Load state from shared preferences
  Future<void> init() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    if (tokens != null) {
      for (String token in tokens) {
        final client = OnlineAnnilClient.fromJson(jsonDecode(token));
        clients[client.id] = client;
      }
    }
    await refresh();
  }

  @override
  void onInit() {
    super.onInit();
    this._network.isOnline.listen((isOnline) {
      this.refresh();
    });
  }

  /// Save the current state of the combined client to shared preferences
  Future<void> save() async {
    final tokens =
        clients.values.map((client) => jsonEncode(client.toJson())).toList();
    Global.preferences.setStringList("annil_clients", tokens);
  }

  /// Remove all remote annil sources
  void syncWithRemote(List<AnnilToken> remoteList) {
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

  /// Refresh all annil servers
  Future<void> refresh() async {
    if (_network.isOnline.value) {
      // wait for a while
      // TODO: refresh after network is actually available
      await Future.delayed(Duration(seconds: 2));
      var newAlbums = (await Future.wait(clients.values.map((client) async {
        try {
          return await client.getAlbums();
        } catch (e) {
          // TODO: failed to get albums, hint user
          return <String>[];
        }
      })))
          .expand((e) => e)
          .toSet()
          .toList();
      albums.replaceRange(0, this.albums.length, newAlbums);
      this.save();
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
    }
    throw new UnsupportedError("No annil client found for album $albumId");
  }

  Widget cover({
    required String albumId,
    int? discId,
    BoxFit? fit,
    double? scale,
    String? tag,
  }) {
    if (!_network.isOnline.value) {
      // offline, load cached cover
      return CoverImage(
        albumId: albumId,
        discId: discId,
        fit: fit ?? BoxFit.scaleDown,
        filterQuality: FilterQuality.medium,
        tag: tag,
      );
    } else {
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
    }

    // try to load from local
    return CoverImage(
      albumId: albumId,
      discId: discId,
      fit: fit ?? BoxFit.scaleDown,
      filterQuality: FilterQuality.medium,
    );
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
