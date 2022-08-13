import 'package:annix/services/annil/annil_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/models/metadata.dart';
import 'package:annix/services/global.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/widgets/album_grid.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeAlbums extends StatelessWidget {
  const HomeAlbums({super.key});

  @override
  Widget build(BuildContext context) {
    final AnnilController annil = Get.find();

    return SliverToBoxAdapter(
      child: Column(
        children: [
          HomeTitle(
            title: I18n.ALBUMS.tr,
            icon: Icons.album_outlined,
            padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              height: 280,
              child: Obx(() {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Obx(
                    () {
                      final albumId = annil.albums[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FutureBuilder<Album?>(
                          future: Global.metadataSource.future.then(
                              (store) => store.getAlbum(albumId: albumId)),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const DummyMusicCover();
                            } else {
                              return AlbumGrid(album: snapshot.data!);
                            }
                          },
                        ),
                      );
                    },
                  ),
                  itemCount: annil.albums.length,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
