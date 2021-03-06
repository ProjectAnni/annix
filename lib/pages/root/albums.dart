import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/root/base.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlbumsView extends StatelessWidget {
  const AlbumsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnnilController annil = Get.find();

    return BaseView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          BaseSliverAppBar(title: Text(I18n.ALBUMS.tr)),
        ];
      },
      body: Obx(
        () {
          return GridView.builder(
            padding: EdgeInsets.all(4.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Global.isDesktop ? 4 : 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: annil.albums.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final albumId = annil.albums[index];
                return AlbumGrid(albumId: albumId);
              });
            },
          );
        },
      ),
    );
  }
}
