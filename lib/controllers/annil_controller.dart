import 'dart:convert';

import 'package:annix/services/annil.dart';
import 'package:annix/services/global.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnilController extends GetxController {
  final RxMap<String, AnnilClient> _clients = Map<String, AnnilClient>().obs;
  final RxList<String> albums = <String>[].obs;

  bool get hasClient => _clients.isNotEmpty;

  /// Load state from shared preferences
  static Future<AnnilController> load() async {
    List<String>? tokens = Global.preferences.getStringList("annil_clients");
    final combined = AnnilController();
    if (tokens != null) {
      for (String token in tokens) {
        final client = AnnilClient.fromJson(jsonDecode(token));
        combined._clients[client.id] = client;
      }
    }
    await combined.refresh();
    return combined;
  }

  /// Save the current state of the combined client to shared preferences
  Future<void> save() async {
    final tokens =
        _clients.values.map((client) => jsonEncode(client.toJson())).toList();
    Global.preferences.setStringList("annil_clients", tokens);
  }

  /// Add a list of clients to the combined client
  Future<void> addAll(List<AnnilClient> clients) async {
    _clients.addAll(Map.fromEntries(clients.map((c) => MapEntry(c.id, c))));
    await save();
  }

  /// Remove all remote annil sources
  Future<void> removeRemote() async {
    _clients.removeWhere((_, client) => !client.local);
  }

  Future<void> refresh() async {
    var newAlbums = (await Future.wait(_clients.values.map((client) async {
      try {
        var albums = await client.getAlbums();
        return albums;
      } catch (e) {
        return <String>[];
      }
    })))
        .expand((e) => e)
        .toSet()
        .toList();
    this.albums.replaceRange(0, this.albums.length, newAlbums);
  }

  Future<AnnilAudioSource> getAudio({
    required String albumId,
    required int discId,
    required int trackId,
    PreferQuality preferBitrate = PreferQuality.Lossless,
  }) {
    for (final client in _clients.values) {
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

  Widget cover({required String albumId, int? discId}) {
    for (final client in _clients.values) {
      if (client.albums.contains(albumId)) {
        return ExtendedImage.network(
          client.getCoverUrl(albumId: albumId, discId: discId),
          cache: true,
          fit: BoxFit.scaleDown,
          filterQuality: FilterQuality.medium,
          imageCacheName: '$albumId/$discId',
        );
      }
    }
    // TODO: return a placeholder
    return Text("No cover");
  }
}
