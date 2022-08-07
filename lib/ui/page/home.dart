import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/playlist/playlist_list.dart';
import 'package:annix/services/global.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/utils/two_side_sliver.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:annix/widgets/buttons/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PlaylistView extends StatelessWidget {
  final AnnivController anniv = Get.find();
  final AnnilController annil = Get.find();

  PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // fav
              return ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: AspectRatio(
                    aspectRatio: 1,
                    child: anniv.favorites.isEmpty
                        ? DummyMusicCover()
                        : MusicCover(
                            albumId: anniv.favorites.values.last.track.albumId),
                  ),
                  title: Text(I18n.MY_FAVORITE.tr),
                  visualDensity: VisualDensity.standard,
                  onTap: () {
                    AnnixBodyPageRouter.toNamed(
                      "/favorite",
                    );
                  });
            } else {
              index = index - 1;
            }

            final playlistId = anniv.playlists.keys.toList()[index];
            final playlist = anniv.playlists[playlistId]!;

            final albumId =
                playlist.cover.albumId == "" ? null : playlist.cover.albumId;
            return ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: AspectRatio(
                aspectRatio: 1,
                child: albumId == null
                    ? DummyMusicCover()
                    : MusicCover(albumId: albumId),
              ),
              title: Text(
                playlist.name,
                overflow: TextOverflow.ellipsis,
              ),
              visualDensity: VisualDensity.standard,
              onTap: () async {
                final playlist =
                    await anniv.client!.getPlaylistDetail(playlistId);
                AnnixBodyPageRouter.to(
                  () => PlaylistDetailScreen(playlist: playlist),
                );
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
  final AnnivController anniv = Get.find();
  final AnnilController annil = Get.find();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FractionallySizedBox(
        widthFactor: Global.isDesktop ? 0.9 : 1,
        alignment: Alignment.center,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: Row(
                children: [
                  CircleAvatar(
                    child:
                        Text(anniv.info.value!.user.nickname.substring(0, 1)),
                  ),
                  SizedBox(width: 8),
                  Text("Welcome back, ${anniv.info.value!.user.nickname}."),
                ],
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.shuffle_outlined),
                  onPressed: () {
                    Provider.of<PlayerService>(context, listen: false)
                        .fullShuffleMode();
                  },
                ),
                ThemeButton(),
              ],
            ),
            ////////////////////////////////////////////////
            _SimpleTitle(
              title: I18n.ALBUMS.tr,
              icon: Icons.album_outlined,
              padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
              sliver: true,
            ),
            SliverPadding(
              padding: EdgeInsets.only(left: 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 280,
                  child: Obx(() {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Obx(
                        () => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: AlbumGrid(albumId: annil.albums[index]),
                        ),
                      ),
                      itemCount: annil.albums.length,
                    );
                  }),
                ),
              ),
            ),
            ////////////////////////////////////////////////
            SliverPadding(
              padding: EdgeInsets.only(top: 48, left: 16, bottom: 16),
              sliver: TwoSideSliver(
                leftPercentage: Global.isDesktop ? 0.5 : 1,
                left: _SimpleTitle(
                  sliver: true,
                  title: I18n.PLAYLISTS.tr,
                  icon: Icons.queue_music_outlined,
                ),
                right: _SimpleTitle(
                  sliver: true,
                  title: I18n.PLAYED_RECENTLY.tr,
                  icon: Icons.music_note_outlined,
                ),
              ),
            ),
            TwoSideSliver(
              leftPercentage: Global.isDesktop ? 0.5 : 1,
              left: PlaylistView(),
              right: SliverToBoxAdapter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool sliver;
  final EdgeInsets? padding;

  const _SimpleTitle({
    required this.icon,
    required this.title,
    this.sliver = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: [
        Icon(icon, size: 28),
        SizedBox(width: 8),
        Text(
          this.title,
          style: context.textTheme.headline5,
        ),
      ],
    );

    if (this.padding != null) {
      child = Padding(
        padding: this.padding!,
        child: child,
      );
    }

    if (this.sliver) {
      child = SliverToBoxAdapter(child: child);
    }

    return child;
  }
}
