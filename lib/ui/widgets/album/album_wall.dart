import 'package:annix/ui/widgets/album/album_grid.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AlbumWall extends StatefulWidget {
  final List<String> albumIds;

  const AlbumWall({super.key, required this.albumIds});

  @override
  State<AlbumWall> createState() => _AlbumWallState();
}

class _AlbumWallState extends State<AlbumWall> {
  @override
  Widget build(final BuildContext context) {
    return MasonryGridView.count(
      primary: false,
      crossAxisCount: context.isDesktopOrLandscape ? 4 : 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemBuilder: (final BuildContext context, final int index) {
        final albumId = widget.albumIds[index];
        return AlbumGrid(
          albumId: albumId,
          style: AlbumGridStyle.card,
        );
      },
      itemCount: widget.albumIds.length,
    );
  }
}
