import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/ui/page/playlist/playlist.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends PlaylistScreen {
  final _anniv = Provider.of<AnnivService>(Global.context, listen: false);

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
  Widget get body => Consumer<AnnivService>(builder: (context, anniv, child) {
        final favorites = anniv.favorites.values.toList().reversed;
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
      .map((t) => TrackIdentifier.fromSlashSplitString(t))
      .toList()
      .reversed
      .toList();

  @override
  Future<void>? get loading => null;
}
