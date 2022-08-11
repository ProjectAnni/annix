import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/services/global.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TagScreen extends StatelessWidget {
  final String name;

  const TagScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AnnilController annil = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<String>>(
          future: Global.metadataSource.future
              .then((metadata) => metadata.getAlbumsByTag(name))
              .then((albums) => albums
                ..removeWhere((album) => !annil.albums.contains(album))),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("No available album."),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(4.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Global.isDesktop ? 4 : 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return AlbumGrid(albumId: snapshot.data![index]);
                },
              );
            } else if (snapshot.hasError) {
              Navigator.of(context).pop();
              return const Center(child: Text('Error'));
            } else {
              return const Center(
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
          }),
    );
  }
}
