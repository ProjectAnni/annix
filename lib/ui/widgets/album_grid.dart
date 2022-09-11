import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlbumGrid extends StatelessWidget {
  final String albumId;
  final double? width;

  const AlbumGrid({super.key, required this.albumId, this.width});

  @override
  Widget build(BuildContext context) {
    final MetadataService metadata = context.read();
    final metadataFuture = metadata.getAlbum(albumId: albumId);

    void toAlbum(BuildContext context) {
      metadataFuture.then((album) {
        if (album != null) {
          AnnixRouterDelegate.of(context).to(name: '/album', arguments: album);
        }
      });
    }

    final child = InkWell(
      onTap: () => toAlbum(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: MusicCover(albumId: albumId, card: false),
            ),
            FutureBuilder<Album?>(
              future: metadataFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      snapshot.data!.fullTitle,
                      style: context.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );

    if (width != null) {
      // fixed size
      return SizedBox(
        width: width!,
        child: child,
      );
    } else {
      // stretch
      return Center(
        child: child,
      );
    }
  }
}
