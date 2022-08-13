import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/anniv.dart';
import 'package:annix/pages/playlist/playlist.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteScreen extends PlaylistScreen {
  final AnnivController _anniv = Get.find();

  @override
  final Widget? pageTitle = null;
  @override
  final List<Widget>? pageActions = null;

  FavoriteScreen({super.key});

  @override
  RefreshCallback? get refresh => () => _anniv.syncFavorite();

  @override
  String get title => I18n.MY_FAVORITE.tr;
  @override
  Widget get cover => _anniv.favorites.keys.isNotEmpty
      ? MusicCover(albumId: _anniv.favorites.keys.last.split('/')[0])
      : const DummyMusicCover();

  @override
  List<Widget> get intro => [
        Text("${_anniv.favorites.length} songs"),
      ];

  @override
  Widget get body => Obx(() {
        final favorites = _anniv.favorites.values.toList().reversed;
        return ListView.builder(
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
              onTap: () {
                super.playFullList(context, initialIndex: index);
              },
            );
          },
        );
      });

  @override
  List<TrackIdentifier> get tracks => _anniv.favorites.keys
      .map((t) => TrackIdentifier.fromSlashSplitedString(t))
      .toList()
      .reversed
      .toList();
}
