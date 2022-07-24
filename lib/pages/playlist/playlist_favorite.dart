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
  Widget get cover => _anniv.favorites.keys.isNotEmpty
      ? _annil.cover(albumId: _anniv.favorites.keys.last.split('/')[0])
      : _annil.cover();

  @override
  List<Widget> get intro => [
        Text("${_anniv.favorites.length} songs"),
      ];

  Widget get body => Obx(() {
        final favorites = _anniv.favorites.values.toList().reversed;
        return ListView.separated(
          itemCount: _anniv.favorites.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final favorite = favorites.elementAt(index);
            return ListTile(
              leading: Text("${index + 1}"),
              minLeadingWidth: 16,
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                favorite.title,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: ArtistText(
                favorite.artist,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(height: 8),
        );
      });

  List<TrackIdentifier> get tracks => _anniv.favorites.keys
      .map((t) => TrackIdentifier.fromSlashSplitedString(t))
      .toList()
      .reversed
      .toList();
}
