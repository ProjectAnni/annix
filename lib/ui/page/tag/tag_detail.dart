import 'package:annix/services/annil/client.dart';
import 'package:annix/global.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/ui/widgets/album_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagDetailScreen extends StatelessWidget {
  final String name;

  const TagDetailScreen({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final annil = context.read<AnnilService>();
    final MetadataService metadata = context.read<MetadataService>();

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<String>>(
          future: metadata.getAlbumsByTag(name).then(
              (albums) => albums.intersection(annil.albums.toSet()).toList()),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No available album.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(4.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: Global.isDesktop ? 4 : 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.87,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final albumId = snapshot.data![index];
                  return AlbumGrid(albumId: albumId);
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
