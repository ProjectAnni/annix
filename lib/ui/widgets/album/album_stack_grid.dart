import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/widgets/artist_text.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_album_grid.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AlbumStackGrid extends StatelessWidget {
  final Album album;
  const AlbumStackGrid({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        MusicCover.fromAlbum(
          albumId: album.albumId,
          fit: BoxFit.cover,
        ),
        Container(
          padding: const EdgeInsets.all(4.0),
          alignment: Alignment.bottomLeft,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.black.withValues(alpha: 0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: context.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
                const SizedBox(height: 4),
                ArtistText(
                  album.artist,
                  style: context.textTheme.labelSmall
                      ?.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingAlbumStackGrid extends ConsumerWidget {
  final String albumId;

  const LoadingAlbumStackGrid({
    super.key,
    required this.albumId,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final album = ref.watch(albumFamily(albumId));

    return album.when(
      data: (album) => AlbumStackGrid(album: album),
      error: (error, stacktrace) => const Text('Error'),
      loading: () => const ShimmerAlbumStackGrid(),
    );
  }
}
