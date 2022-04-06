import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/pages/root/base.dart';
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
          SliverAppBar(
            title: Text("Albums"),
            primary: false,
            snap: true,
            floating: true,
            centerTitle: true,
          ),
        ];
      },
      body: GridView.custom(
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
      ),
    );
  }
}
