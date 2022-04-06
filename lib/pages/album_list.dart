import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AlbumList extends StatelessWidget {
  const AlbumList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnilController annil = Get.find();

    return GridView.custom(
      padding: EdgeInsets.all(4.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
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
