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

    return Column(
      children: [
        BaseAppBar(title: Text(I18n.PLAYLISTS.tr)),
        Expanded(
          child: Obx(
            () => ListView.separated(
              itemCount: anniv.playlists.length,
              itemBuilder: (context, index) {
                final playlistId = anniv.playlists.keys.toList()[index];
                final playlist = anniv.playlists[playlistId]!;
                return ListTile(
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: annil.cover(
                      albumId: playlist.cover.albumId == ""
                          ? null
                          : playlist.cover.albumId,
                    ),
                  ),
                  title: Text(playlist.name),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () async {
                    final playlist =
                        await anniv.client!.getPlaylistDetail(playlistId);
                    Get.to(
                      () => PlaylistDetailScreen(playlist: playlist),
                      id: 1,
                    );
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(),
            ),
          ),
        ),
      ],
    );
  }
}
