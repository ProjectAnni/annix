import 'package:annix/services/metadata/metadata.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AlbumGridStyle {
  card,
  none,
}

class AlbumGrid extends StatelessWidget {
  final String albumId;
  final AlbumGridStyle style;

  const AlbumGrid({
    super.key,
    required this.albumId,
    this.style = AlbumGridStyle.card,
  });

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

    final child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: MusicCover(
            albumId: albumId,
            card: false,
            fit: BoxFit.fitHeight,
          ),
        ),
        FutureBuilder<Album?>(
          future: metadataFuture,
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 26,
                    child: Text(
                      snapshot.data?.fullTitle ?? '',
                      style: context.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    height: 17,
                    child: Text(
                      snapshot.data?.artist ?? '',
                      style: context.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    if (style == AlbumGridStyle.card) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => toAlbum(context),
        child: Card(
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
      );
    } else {
      return child;
    }
  }
}
