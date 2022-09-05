import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/player.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/global.dart';
import 'package:annix/ui/page/home/home_albums.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/utils/two_side_sliver.dart';
import 'package:annix/ui/widgets/buttons/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: (<Widget>[
                  Consumer<AnnivService>(
                    builder: (context, anniv, child) {
                      return SliverAppBar.large(
                        title: HomeAppBar(info: anniv.info),
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
                              context
                                  .read<PlayerService>()
                                  .fullShuffleMode(context)
                                  .then(
                                (value) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              AnnixRouterDelegate.of(context)
                                  .to(name: "/search");
                            },
                          ),
                          const ThemeButton(),
                        ],
                      );
                    },
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
