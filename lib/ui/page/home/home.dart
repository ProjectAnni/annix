import 'package:annix/ui/page/home/home_action_grid.dart';
import 'package:annix/ui/page/home/home_appbar.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) {
          return [
            const HomeAppBar(),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            primary: false,
            slivers: content(context),
          ),
        ),
      ),
    );
  }

  List<Widget> content(final BuildContext context) {
    return <Widget>[
      const SliverToBoxAdapter(child: HomeActionGrid()),

      ////////////////////////////////////////////////
      HomeTitle(
        sliver: true,
        title: t.playlists,
        icon: Icons.queue_music_outlined,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      const PlaylistView(),
    ];
  }
}
