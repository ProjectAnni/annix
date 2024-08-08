import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum AlbumGridStyle {
  card,
  none,
}

class AlbumGrid extends ConsumerWidget {
  final String albumId;
  final AlbumGridStyle style;

  const AlbumGrid({
    super.key,
    required this.albumId,
    this.style = AlbumGridStyle.card,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final metadata = ref.read(metadataProvider);
    final metadataFuture = metadata.getAlbum(albumId: albumId);

    void toAlbum(final BuildContext context) {
      ref.read(routerProvider).to(name: '/album', arguments: albumId);
    }

    final child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: MusicCover.fromAlbum(
            albumId: albumId,
            fit: BoxFit.fitHeight,
          ),
        ),
        FutureBuilder<Album?>(
          future: metadataFuture,
          builder: (final context, final snapshot) {
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
                    child: ArtistText(
                      snapshot.data?.artist ?? '',
                      style: context.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
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
