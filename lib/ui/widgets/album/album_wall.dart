import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/widgets/album/album_grid.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AlbumWall extends StatelessWidget {
  final List<Album> albums;
  const AlbumWall({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      primary: false,
      crossAxisCount: context.isDesktopOrLandscape ? 4 : 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (final BuildContext context, final int index) {
        final album = albums[index];
        return AlbumGrid(
          album: album,
          style: AlbumGridStyle.card,
        );
      },
      itemCount: albums.length,
    );
  }
}

class LazyAlbumWall extends StatelessWidget {
  final List<String> albumIds;
  final bool showFavorite;
  const LazyAlbumWall(
      {super.key, required this.albumIds, this.showFavorite = true});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      primary: false,
      crossAxisCount: context.isDesktopOrLandscape ? 4 : 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: EdgeInsets.zero,
      itemBuilder: (final BuildContext context, final int index) {
        final albumId = albumIds[index];
        return LoadingAlbumGrid(
          albumId: albumId,
          style: AlbumGridStyle.card,
          showFavorite: showFavorite,
        );
      },
      itemCount: albumIds.length,
    );
  }
}

class LazySliverAlbumWall extends StatelessWidget {
  final List<String> albumIds;
  final bool showFavorite;
  const LazySliverAlbumWall({
    super.key,
    required this.albumIds,
    this.showFavorite = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: context.isDesktopOrLandscape ? 4 : 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (final BuildContext context, final int index) {
        final albumId = albumIds[index];
        return LoadingAlbumGrid(
          albumId: albumId,
          style: AlbumGridStyle.card,
          showFavorite: showFavorite,
        );
      },
      childCount: albumIds.length,
    );
  }
}
