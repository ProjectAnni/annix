import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/playlist/playlist_list.dart';
import 'package:annix/pages/root/base.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistsView extends StatelessWidget {
  const PlaylistsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnivController anniv = Get.find();
    final AnnilController annil = Get.find();

    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(title: Text(I18n.PLAYLISTS.tr)),
        ];
      },
      body: Obx(
        () => ListView(
          children: anniv.playlists.values
              .map(
                (e) => ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(4),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: annil.cover(
                        albumId: e.cover.albumId == "" ? null : e.cover.albumId,
                      ),
                    ),
                  ),
                  title: Text(e.name),
                  onTap: () async {
                    final playlist =
                        await anniv.client!.getPlaylistDetail(e.id);
                    Get.to(
                      () => PlaylistDetailScreen(playlist: playlist),
                    );
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
