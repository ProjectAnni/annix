import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/album/album_wall.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TagDetailScreen extends ConsumerWidget {
  final String name;

  const TagDetailScreen({super.key, required this.name});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final annil = ref.read(annilProvider);
    final metadata = ref.read(metadataProvider);

    // TODO: do not use FutureBuilder
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder<List<String>>(
          future: metadata.getAlbumsByTag(name).then((final albums) =>
              albums.intersection(annil.albums.toSet()).toList()),
          builder: (final context, final snapshot) {
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
