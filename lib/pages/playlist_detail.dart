import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/widgets/artist_text.dart';
import 'package:annix/widgets/buttons/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteDetail extends StatelessWidget {
  const FavoriteDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();
    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.MY_FAVORITE.tr),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: anniv.favorites.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return Obx(() {
              final favorite = anniv.favorites.values.elementAt(index);
              return ListTile(
                // leading: FavoriteButton(id: favorite.track.toSlashedString()),
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
      }),
    );
  }
}

class PlaylistDetail extends StatelessWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
