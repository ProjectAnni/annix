import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/services/platform.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AlbumList extends StatelessWidget {
  const AlbumList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnilController annil = Get.find();

    return GridView.custom(
      padding: EdgeInsets.all(24.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: AnniPlatform.isDesktop ? 5 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 32,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == annil.albums.length) {
            return null;
          }

          var albumId = annil.albums[index];
          return AlbumGrid(
            albumId: albumId,
            cover: annil.cover(albumId: albumId),
          );
        },
      ),
    );
  }
}
