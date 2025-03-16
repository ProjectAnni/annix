import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/buttons/favorite_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_album_grid.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum AlbumGridStyle {
  card,
  none,
}

class AlbumGrid extends ConsumerWidget {
  final Album album;
  final AlbumGridStyle style;
  final bool showFavorite;

  const AlbumGrid({
    super.key,
    required this.album,
    required this.style,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void toAlbum(final BuildContext context) {
      context.push('/album', extra: album.albumId);
    }

    final child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: MusicCover.fromAlbum(
                albumId: album.albumId,
                fit: BoxFit.fitHeight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                color: context.colorScheme.secondaryContainer,
                elevation: 4,
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(24),
                child: showFavorite
                    ? FavoriteAlbumButton(albumId: album.albumId)
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 26,
                child: Text(
                  album.title,
                  style: context.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(
                height: 17,
                child: ArtistText(
                  album.artist,
                  style: context.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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

class LoadingAlbumGrid extends ConsumerWidget {
  final String albumId;
  final AlbumGridStyle style;
  final bool showFavorite;

  const LoadingAlbumGrid({
    super.key,
    required this.albumId,
    this.style = AlbumGridStyle.card,
    this.showFavorite = true,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final album = ref.watch(albumFamily(albumId));

    return album.when(
      data: (album) => AlbumGrid(
        album: album,
        style: style,
        showFavorite: showFavorite,
      ),
      error: (error, stacktrace) => const Text('Error'),
      loading: () => ShimmerAlbumGrid(albumId: albumId),
    );
  }
}
