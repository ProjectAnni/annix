import 'dart:convert';

import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnilController extends GetxController {
  final RxMap<String, AnnilClient> clients = Map<String, AnnilClient>().obs;
  final RxList<String> albums = <String>[].obs;

  bool get hasClient => clients.isNotEmpty;

  /// Load state from shared preferences
  Future<void> init() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    if (tokens != null) {
      for (String token in tokens) {
        final client = AnnilClient.fromJson(jsonDecode(token));
        clients[client.id] = client;
      }
    }
    await refresh();
  }

  /// Save the current state of the combined client to shared preferences
  Future<void> save() async {
    final tokens =
        clients.values.map((client) => jsonEncode(client.toJson())).toList();
    Global.preferences.setStringList("annil_clients", tokens);
  }

  /// Add a list of clients to the combined client
  Future<void> addClients(List<AnnilClient> newClients) async {
    clients.addAll(Map.fromEntries(newClients.map((c) => MapEntry(c.id, c))));
    await save();
  }

  /// Remove all remote annil sources
  void removeRemote() {
    // 1. remove clients
    clients.removeWhere((_, client) => !client.local);
    // 2. scan current clients, generate new albums list
    albums.replaceRange(0, this.albums.length,
        clients.values.map((e) => e.albums).expand((e) => e).toSet().toList());
    albums.refresh();
  }

  /// Refresh all annil servers
  Future<void> refresh() async {
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
    albums.refresh();
  }

  Future<AnnilAudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
    PreferQuality preferBitrate = PreferQuality.Lossless,
  }) {
    for (final client in clients.values) {
      if (client.albums.contains(albumId)) {
        return AnnilAudioSource.create(
          annil: client,
          albumId: albumId,
          discId: discId,
          trackId: trackId,
          preferBitrate: preferBitrate,
        );
      }
    }
    throw new UnsupportedError("No annil client found for album $albumId");
  }

  Widget cover(
      {required String albumId, int? discId, BoxFit? fit, double? scale}) {
    for (final client in clients.values) {
      if (client.albums.contains(albumId)) {
        return ExtendedImage.network(
          client.getCoverUrl(albumId: albumId, discId: discId),
          cache: true,
          fit: fit ?? BoxFit.scaleDown,
          filterQuality: FilterQuality.medium,
          imageCacheName: '$albumId/$discId',
          scale: scale ?? 1.0,
        );
      }
    }
    print(clients);
    print(albumId);
    return Container(
      alignment: Alignment.center,
      color: Colors.blueGrey,
      child: Text("Cover not available"),
    );
  }
}
