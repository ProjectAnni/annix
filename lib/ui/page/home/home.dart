import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/ui/page/home/home_albums.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/ui/widgets/utils/two_side_sliver.dart';
import 'package:annix/ui/widgets/buttons/theme_button.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              title: const HomeAppBar(),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    AnnixRouterDelegate.of(context).to(name: '/downloading');
                  },
                ),
                // IconButton(
                //   icon: const Icon(Icons.shuffle_outlined),
                //   onPressed: () {
                //     showLoadingDialog(context);
                //     context
                //         .read<PlaybackService>()
                //         .fullShuffleMode(context)
                //         .then(
                //       (value) {
                //         Navigator.of(context, rootNavigator: true).pop();
                //       },
                //     );
                //   },
                // ),
                if (!context.isDesktopOrLandscape)
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      AnnixRouterDelegate.of(context).to(name: '/search');
                    },
                  ),
                const ThemeButton(),
              ],
            ),
          ];
        },
        body: CustomScrollView(
          slivers: content(context)
              .map((sliver) => SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    sliver: sliver,
                  ))
              .toList(),
        ),
      ),
    );
  }

  List<Widget> content(BuildContext context) {
    return <Widget>[
      const HomeAlbums(),

      ////////////////////////////////////////////////
      SliverPadding(
        padding: const EdgeInsets.only(top: 48, left: 16, bottom: 16),
        sliver: TwoSideSliver(
          leftPercentage: context.isDesktopOrLandscape ? 0.5 : 1,
          left: HomeTitle(
            sliver: true,
            title: t.playlists,
            icon: Icons.queue_music_outlined,
          ),
          right: HomeTitle(
            sliver: true,
            title: t.recent_played,
            icon: Icons.music_note_outlined,
          ),
        ),
      ),
      TwoSideSliver(
        leftPercentage: context.isDesktopOrLandscape ? 0.5 : 1,
        left: const PlaylistView(),
        right: const SliverToBoxAdapter(),
      ),
    ];
  }
}
