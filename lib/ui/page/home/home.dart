import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/page/home/home_albums.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/utils/two_side_sliver.dart';
import 'package:annix/ui/widgets/buttons/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatelessWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivService>(context, listen: false);
    return Obx(
      () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // fav
              return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: anniv.favorites.isEmpty
                        ? const DummyMusicCover()
                        : MusicCover(
                            albumId: anniv.favorites.values.last.track.albumId),
                  ),
                  title: Text(I18n.MY_FAVORITE.tr),
                  visualDensity: VisualDensity.standard,
                  onTap: () {
                    AnnixRouterDelegate.of(context).to(name: "/favorite");
                  });
            } else {
              index = index - 1;
            }

            final playlistId = anniv.playlists.keys.toList()[index];
            final playlist = anniv.playlists[playlistId]!;

            final albumId =
                playlist.cover.albumId == "" ? null : playlist.cover.albumId;
            return ListTile(
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
                final playlist = await anniv.getPlaylist(playlistId);
                delegate.to(name: "/playlist", arguments: playlist);
              },
            );
          },
          childCount: anniv.playlists.length + 1,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final anniv = Provider.of<AnnivService>(context, listen: false);

    return Material(
      child: CustomScrollView(
        slivers: (<Widget>[
                  SliverAppBar.large(
                    title: Obx(() => HomeAppBar(info: anniv.info.value)),
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    scrolledUnderElevation: 0,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.shuffle_outlined),
                        onPressed: () {
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            barrierDismissible: false,
                            builder: (context) {
                              return Center(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                        SizedBox(width: 12),
                                        Text("Loading..."),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                          Provider.of<PlayerService>(context, listen: false)
                              .fullShuffleMode()
                              .then((value) =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          AnnixRouterDelegate.of(context).to(name: "/search");
                        },
                      ),
                      const ThemeButton(),
                    ],
                  ),
                ] +
                content())
            .map(
              (sliver) => SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                ),
                sliver: sliver,
              ),
            )
            .toList(),

        // (anniv.info.value != null ? content() : []),
      ),
    );
  }

  List<Widget> content() {
    return <Widget>[
      const HomeAlbums(),

      ////////////////////////////////////////////////
      SliverPadding(
        padding: const EdgeInsets.only(top: 48, left: 16, bottom: 16),
        sliver: TwoSideSliver(
          leftPercentage: Global.isDesktop ? 0.5 : 1,
          left: HomeTitle(
            sliver: true,
            title: I18n.PLAYLISTS.tr,
            icon: Icons.queue_music_outlined,
          ),
          right: HomeTitle(
            sliver: true,
            title: I18n.PLAYED_RECENTLY.tr,
            icon: Icons.music_note_outlined,
          ),
        ),
      ),
      TwoSideSliver(
        leftPercentage: Global.isDesktop ? 0.5 : 1,
        left: const PlaylistView(),
        right: const SliverToBoxAdapter(),
      ),
    ];
  }
}
