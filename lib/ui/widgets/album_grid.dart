import 'package:annix/models/metadata.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';

class AlbumGrid extends StatelessWidget {
  final Album album;

  const AlbumGrid({super.key, required this.album});

  void toAlbum(BuildContext context) {
    AnnixRouterDelegate.of(context).to(name: '/album', arguments: album);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 0.86,
        child: GestureDetector(
          onTap: () => toAlbum(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => toAlbum(context),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: MusicCover(albumId: album.albumId),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  album.title,
                  style: context.textTheme.titleMedium,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
