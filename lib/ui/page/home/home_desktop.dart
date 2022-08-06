import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/playlist/playlist_list.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/widgets/album_grid.dart';
import 'package:annix/widgets/buttons/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleTitle extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool sliver;
  final EdgeInsets? padding;

  const SimpleTitle({
    super.key,
    required this.icon,
    required this.title,
    this.sliver = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Row(
      children: [
        this.icon,
        SizedBox(width: 8),
        Text(
          this.title,
          style: context.textTheme.titleLarge,
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

class DesktopHomePage extends StatelessWidget {
  final AnnivController anniv = Get.find();
  final AnnilController annil = Get.find();

  DesktopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scrollbar(
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
                    final PlayerController player = Get.find();
                    player.fullShuffleMode();
                  },
                ),
                ThemeButton(),
              ],
            ),
            ////////////////////////////////////////////////
            SimpleTitle(
              title: "Albums",
              icon: Icon(
                Icons.album_outlined,
                size: 28,
              ),
              padding: EdgeInsets.only(left: 16, bottom: 8),
              sliver: true,
            ),
            SliverPadding(
              padding: EdgeInsets.only(left: 16),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 200,
                  child: Obx(() {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Obx(
                        () => AlbumGrid(albumId: annil.albums[index]),
                      ),
                      itemCount: annil.albums.length,
                    );
                  }),
                ),
              ),
            ),
            ////////////////////////////////////////////////
            SliverPadding(padding: EdgeInsets.only(top: 24)),
            SliverToBoxAdapter(
              child: Container(
                height: 360,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SimpleTitle(
                            title: "Playlists",
                            icon: Icon(
                              Icons.queue_music_outlined,
                              size: 28,
                            ),
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                          ),
                          Expanded(
                            child: Obx(
                              () => ListView.builder(
                                itemCount: anniv.playlists.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    // fav
                                    return ListTile(
                                        leading: AspectRatio(
                                          aspectRatio: 1,
                                          child: anniv.favorites.isEmpty
                                              ? DummyMusicCover()
                                              : MusicCover(
                                                  albumId: anniv
                                                      .favorites
                                                      .values
                                                      .last
                                                      .track
                                                      .albumId),
                                        ),
                                        title: Text(I18n.MY_FAVORITE.tr),
                                        visualDensity:
                                            VisualDensity.comfortable,
                                        onTap: () {
                                          AnnixBodyPageRouter.toNamed(
                                            "/favorite",
                                          );
                                        });
                                  } else {
                                    index = index - 1;
                                  }

                                  final playlistId =
                                      anniv.playlists.keys.toList()[index];
                                  final playlist = anniv.playlists[playlistId]!;

                                  final albumId = playlist.cover.albumId == ""
                                      ? null
                                      : playlist.cover.albumId;
                                  return ListTile(
                                    leading: AspectRatio(
                                      aspectRatio: 1,
                                      child: albumId == null
                                          ? DummyMusicCover()
                                          : MusicCover(albumId: albumId),
                                    ),
                                    title: Text(playlist.name),
                                    visualDensity: VisualDensity.comfortable,
                                    onTap: () async {
                                      final playlist = await anniv.client!
                                          .getPlaylistDetail(playlistId);
                                      AnnixBodyPageRouter.to(
                                        () => PlaylistDetailScreen(
                                            playlist: playlist),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SimpleTitle(
                            title: "Recently played",
                            icon: Icon(
                              Icons.music_note_outlined,
                              size: 28,
                            ),
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
