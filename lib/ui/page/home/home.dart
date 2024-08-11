import 'package:annix/providers.dart';
import 'package:annix/ui/page/home/home_action_grid.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/home/home_title.dart';
import 'package:annix/ui/widgets/anniv/anniv_not_login_card.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (final context, final innerBoxIsScrolled) {
          return [
            if (context.isMobileOrPortrait)
              SliverAppBar(
                title: Text(
                  t.home,
                  // style: context.textTheme.displayMedium,
                ),
                floating: false,
                actions: [
                  Consumer(builder: (context, ref, child) {
                    final info =
                        ref.watch(annivProvider.select((final v) => v.info));
                    if (info != null) {
                      return IconButton(
                        icon: CircleAvatar(
                          child: Text(info.user.nickname.substring(0, 1)),
                        ),
                        onPressed: () {
                          ref.read(routerProvider).to(name: '/server');
                        },
                      );
                    } else {
                      return Container();
                    }
                  })
                ],
              ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer(
            builder: (context, ref, child) => CustomScrollView(
              primary: false,
              slivers: content(context, ref),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> content(final BuildContext context, WidgetRef ref) {
    final annivInfo = ref.watch(annivProvider.select((final v) => v.info));
    return <Widget>[
      if (annivInfo == null)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: AnnivNotLoginCard(),
          ),
        ),

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
