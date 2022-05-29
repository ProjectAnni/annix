import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteScreen extends PlaylistScreen {
  final AnnilController _annil = Get.find();
  final AnnivController _anniv = Get.find();

  FavoriteScreen({Key? key}) : super(key: key);

  String get title => I18n.MY_FAVORITE.tr;
  Widget get cover =>
      _annil.cover(albumId: _anniv.favorites.keys.first.split('/')[0]);

  Widget get body => Obx(() {
        return ListView.builder(
          itemCount: _anniv.favorites.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return Obx(() {
              final favorite = _anniv.favorites.values.elementAt(index);
              return ListTile(
                title: Text(
                  favorite.title,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: ArtistText(
                  favorite.artist,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            });
          },
        );
      });

  List<TrackIdentifier> get tracks => _anniv.favorites.keys
      .map((t) => TrackIdentifier.fromSlashSplitedString(t))
      .toList();
}
