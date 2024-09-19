import 'package:annix/providers.dart';
import 'package:annix/ui/page/favorite.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/playback_history.dart';
import 'package:annix/ui/widgets/album/album_stack_grid.dart';
import 'package:annix/ui/widgets/anniv/anniv_not_login_card.dart';
import 'package:annix/ui/widgets/buttons/theme_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum FilterType { all, favorite, playlist, history }

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final filter = useState(FilterType.all);
    final isAllPage = filter.value == FilterType.all;
    final isFavoritePage = filter.value == FilterType.favorite;
    final isPlaylistPage = filter.value == FilterType.playlist;
    final isHistoryPage = filter.value == FilterType.history;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            if (context.isMobileOrPortrait)
              SliverAppBar(
                floating: true,
                title: const Text('Annix'),
                actions: [
                  const ThemeButton(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      context.push('/settings');
                    },
                  ),
                ],
              ),

            SliverToBoxAdapter(
              child: OverflowBar(
                // scrollDirection: Axis.horizontal,
                alignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text("All"),
                    onSelected: (selected) {
                      if (selected) {
                        filter.value = FilterType.all;
                      }
                    },
                    selected: isAllPage,
                  ),
                  FilterChip(
                    label: Text(t.my_favorite),
                    onSelected: (selected) {
                      if (selected) {
                        filter.value = FilterType.favorite;
                      } else {
                        filter.value = FilterType.all;
                      }
                    },
                    selected: isFavoritePage,
                  ),
                  FilterChip(
                    label: Text(t.playlists),
                    onSelected: (selected) {
                      if (selected) {
                        filter.value = FilterType.playlist;
                      } else {
                        filter.value = FilterType.all;
                      }
                    },
                    selected: isPlaylistPage,
                  ),
                  FilterChip(
                    label: const Text('History'),
                    onSelected: (selected) {
                      if (selected) {
                        filter.value = FilterType.history;
                      } else {
                        filter.value = FilterType.all;
                      }
                    },
                    selected: isHistoryPage,
                  )
                ],
              ),
            ),

            ...content(context),

            ///////////////////////////// ALL /////////////////////////////
            if (isAllPage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // [BEGIN] Statistics Card
            if (isAllPage) const SliverToBoxAdapter(child: StatisticsCard()),
            if (isAllPage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // [END] Statistics Card

            // [BEGIN] New Albums
            if (isAllPage)
              HomePageSectionTitle(
                title: 'New Albums',
                trailing: TextButton(
                  child: Text('More'),
                  onPressed: () {},
                ),
              ),
            if (isAllPage)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 232,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final annil = ref.watch(annilProvider);
                      return CarouselView.weighted(
                        flexWeights: const [2, 1],
                        itemSnapping: true,
                        padding: const EdgeInsets.only(right: 4),
                        children: annil.albums.slice(0, 10).map((albumId) {
                          return Stack(
                            fit: StackFit.passthrough,
                            children: [
                              MusicCover.fromAlbum(
                                albumId: albumId,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                alignment: Alignment.bottomLeft,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.black.withValues(alpha: 0.5),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 16,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Album Name',
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Released on 2024/07/21',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            if (isAllPage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // [END] New Albums

            ///////////////////////////// FAVORITE /////////////////////////////
            if (isFavoritePage)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            // [BEGIN] Favorite Albums
            if (isFavoritePage)
              HomePageSectionTitle(
                title: 'Albums',
                trailing: TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text('View All'),
                  onPressed: () {},
                ),
              ),
            if (isFavoritePage)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final favoriteAlbums = ref.watch(favoriteAlbumsProvider);
                      final favorites = favoriteAlbums.value ?? [];
                      final reversedFavorite = favorites.reversed
                          .map((final e) => e.albumId)
                          .toList();
                      return CarouselView.weighted(
                        flexWeights: const [6, 3, 1],
                        padding: const EdgeInsets.only(right: 4),
                        onTap: (index) => context.push(
                          '/album',
                          extra: reversedFavorite[index],
                        ),
                        children: reversedFavorite
                            .slice(0, 10)
                            .map((albumId) =>
                                LoadingAlbumStackGrid(albumId: albumId))
                            .toList(),
                      );
                    },
                  ),
                ),
              ),
            if (isFavoritePage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // [END] Favorite Albums

            // [BEGIN] Favorite Tracks
            if (isFavoritePage)
              HomePageSectionTitle(
                title: 'Songs',
                trailing: FilledButton.tonal(
                  child: Text('Play'),
                  onPressed: () {},
                ),
              ),
            if (isFavoritePage) const FavoriteTracks(),
            if (isFavoritePage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

            ///////////////////////////// PLAYLIST /////////////////////////////
            // [BEGIN] Playlists
            if (isPlaylistPage)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (isPlaylistPage) const PlaylistView(),

            ///////////////////////////// HISTORY /////////////////////////////
            if (isHistoryPage)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // [BEGIN] Playback History
            if (isHistoryPage)
              SliverToBoxAdapter(
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24),
                        Text(
                          'Check your Top Played Songs',
                          style: context.textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Which song do you play most?',
                          style: context.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 16),
                        FilledButton.tonal(
                          onPressed: () => context.push('/history'),
                          child: Text("Let's go!"),
                        ),
                        SizedBox(height: 21),
                      ],
                    ),
                  ),
                ),
              ),
            if (isHistoryPage)
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isHistoryPage)
              const HomePageSectionTitle(title: 'Songs played recently'),
            if (isHistoryPage) const SliverPlaybackHistoryList(),
          ].mapIndexed((index, sliver) {
            if (index == 0) {
              return sliver;
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: sliver,
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> content(final BuildContext context) {
    return <Widget>[
      SliverToBoxAdapter(
        child: Consumer(
          builder: (context, ref, child) {
            final annivInfo =
                ref.watch(annivProvider.select((final v) => v.info));

            if (annivInfo == null) {
              return child!;
            } else {
              return Container();
            }
          },
          child: const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: AnnivNotLoginCard(),
            ),
          ),
        ),
      ),
    ];
  }
}

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: context.colorScheme.primaryContainer,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 20.0,
          left: 16,
          right: 16,
          bottom: 20.0,
        ),
        child: Column(
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Statistics',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text('View Details'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Flexible(
                  child: StatisticItem(
                    icon: Icons.play_circle_outline,
                    title: '1 Songs Played',
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: StatisticItem(
                    icon: Icons.history_outlined,
                    title: '1 Hour Played',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Flexible(
                  child: StatisticItem(
                    icon: Icons.calendar_month_outlined,
                    title: '123 Days',
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final annil = ref.watch(annilProvider);
                      return StatisticItem(
                        icon: Icons.album_outlined,
                        title: '${annil.albums.length} Albums',
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const StatisticItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: ElevationOverlay.applySurfaceTint(
        context.colorScheme.primaryFixedDim,
        context.colorScheme.surfaceTint,
        4.0,
      ),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: context.colorScheme.onPrimaryFixed,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.onPrimaryFixed,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomePageSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const HomePageSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleLarge,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
