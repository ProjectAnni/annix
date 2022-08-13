import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class DummyAlbumGrid extends StatelessWidget {
  final double? width;

  const DummyAlbumGrid({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    final child = Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DummyMusicCover(),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              "",
              style: context.textTheme.titleSmall,
            ),
          ),
        ],
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
        child: AspectRatio(
          aspectRatio: 0.82,
          child: child,
        ),
      );
    }
  }
}

class AlbumGrid extends StatelessWidget {
  final Album album;
  final double? width;

  const AlbumGrid({super.key, required this.album, this.width});

  void toAlbum(BuildContext context) {
    AnnixRouterDelegate.of(context).to(name: '/album', arguments: album);
  }

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: () => toAlbum(context),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MusicCover(albumId: album.albumId),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                album.title,
                style: context.textTheme.titleSmall,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
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
        child: AspectRatio(
          aspectRatio: 0.82,
          child: child,
        ),
      );
    }
  }
}
