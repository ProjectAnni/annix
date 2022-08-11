import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/widgets/album_grid.dart';
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
                    () => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AlbumGrid(albumId: annil.albums[index]),
                    ),
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
