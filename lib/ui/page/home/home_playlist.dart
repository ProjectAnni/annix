import 'package:annix/services/local/database.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:flutter/material.dart';
import 'package:morpheus/page_routes/morpheus_page_transition.dart';
import 'package:morpheus/page_routes/morpheus_route_arguments.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<List<PlaylistData>>(
      builder: (context, playlists, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final playlist = playlists[index];

              final albumId =
                  playlist.cover == null ? null : playlist.cover!.split('/')[0];

              final parentKey = GlobalKey();
              return ListTile(
                key: parentKey,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: albumId == null
                      ? const DummyMusicCover()
                      : MusicCover(albumId: albumId),
                ),
                title: Text(
                  playlist.name,
                  overflow: TextOverflow.ellipsis,
                ),
                visualDensity: VisualDensity.standard,
                onTap: () async {
                  final delegate = AnnixRouterDelegate.of(context);
                  delegate.to(
                    name: '/playlist',
                    arguments: playlist.id,
                    pageBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final renderBox = _findRenderBox(parentKey);
                      final size = renderBox?.size;
                      final offset = renderBox?.localToGlobal(Offset.zero);
                      return MorpheusPageTransition(
                        renderBox: renderBox,
                        renderBoxSize: size,
                        renderBoxOffset: offset,
                        context: context,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        settings: MorpheusRouteArguments(
                          parentKey: parentKey,
                          scrimColor: Colors.transparent,
                        ),
                        child: child,
                      );
                    },
                  );
                },
              );
            },
            childCount: playlists.length,
          ),
        );
      },
    );
  }
}

RenderBox? _findRenderBox(GlobalKey key) {
  // Find the [RenderBox] attached to [key].
  return key.currentContext?.findRenderObject() as RenderBox?;
}
