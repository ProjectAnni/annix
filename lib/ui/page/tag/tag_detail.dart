import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagDetailScreen extends StatelessWidget {
  final String name;

  const TagDetailScreen({super.key, required this.name});

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

              return AlbumWall(albumIds: snapshot.data!);
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
