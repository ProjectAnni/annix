import 'package:annix/providers.dart';
import 'package:annix/ui/page/favorite.dart';
import 'package:annix/ui/page/home/home_playlist.dart';
import 'package:annix/ui/page/playback_history.dart';
import 'package:annix/ui/widgets/album/album_stack_grid.dart';
import 'package:annix/ui/widgets/buttons/theme_button.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/gaps.dart';
import 'package:annix/ui/widgets/section_title.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum FilterType { all, favorite, playlist, history }

class PersistentHomeHeader extends SliverPersistentHeaderDelegate {
  final ValueNotifier<FilterType> filter;
  const PersistentHomeHeader({required this.filter});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isAllPage = filter.value == FilterType.all;
    final isFavoritePage = filter.value == FilterType.favorite;
    final isPlaylistPage = filter.value == FilterType.playlist;
    final isHistoryPage = filter.value == FilterType.history;

    return Material(
      elevation: overlapsContent ? 3.0 : 0.0,
      child: Container(
        color: overlapsContent
            ? context.colorScheme.surfaceContainerHigh
            : context.colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
        child: Row(
          spacing: 8.0,
          children: [
            FilterChip(
              label: const Text('All'),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(final BuildContext context) {
    final filter = useState(FilterType.favorite);
    final isAllPage = filter.value == FilterType.all;
    final isFavoritePage = filter.value == FilterType.favorite;
    final isPlaylistPage = filter.value == FilterType.playlist;
    final isHistoryPage = filter.value == FilterType.history;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            leadingWidth: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              title: Text(
                'Annix',
                style: context.textTheme.titleLarge?.copyWith(
                  color: context.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              expandedTitleScale: 1.5,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => context.push('/playground'),
              ),
              const ThemeButton(),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),

          SliverPersistentHeader(
            pinned: true,
            delegate: PersistentHomeHeader(filter: filter),
          ),

          ///////////////////////////// ALL /////////////////////////////
          // [BEGIN] Statistics Card
          if (isAllPage) const SliverToBoxAdapter(child: StatisticsCard()),
          if (isAllPage) const SliverGap.betweenSections(),
          // [END] Statistics Card

          // [BEGIN] New Albums
          if (isAllPage)
            SectionTitle(
              title: 'New Albums',
              trailing: TextButton(
                child: const Text('More'),
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
                    final data = annil.albums.take(10);
                    if (data.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return CarouselView.weighted(
                      flexWeights: context.isDesktopOrLandscape
                          ? const [5, 4, 4, 2, 1]
                          : const [2, 1],
                      itemSnapping: true,
                      padding: const EdgeInsets.only(right: 4),
                      children: data.map((albumId) {
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
          if (isAllPage) const SliverGap.betweenSections(),
          // [END] New Albums

          ///////////////////////////// FAVORITE /////////////////////////////
          // [BEGIN] Favorite Albums
          if (isFavoritePage)
            SectionTitle(
              title: 'Albums',
              leading: const Icon(Icons.album_outlined),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('View All'),
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
                    final reversedFavorite =
                        favorites.reversed.map((final e) => e.albumId).toList();
                    return CarouselView.weighted(
                      flexWeights: context.isDesktopOrLandscape
                          ? const [4, 3, 3, 2, 1]
                          : const [5, 3, 2],
                      padding: const EdgeInsets.only(right: 4),
                      onTap: (index) => context.push(
                        '/album',
                        extra: reversedFavorite[index],
                      ),
                      children: reversedFavorite
                          .take(10)
                          .map((albumId) =>
                              LoadingAlbumStackGrid(albumId: albumId))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          if (isFavoritePage) const SliverGap.betweenSections(),
          // [END] Favorite Albums

          // [BEGIN] Favorite Tracks
          if (isFavoritePage)
            SectionTitle(
              title: 'Songs',
              leading: const Icon(Icons.list),
              trailing: FilledButton.tonal(
                child: const Text('Play'),
                onPressed: () {},
              ),
            ),
          if (isFavoritePage) const FavoriteTracks(),
          if (isFavoritePage) const SliverGap.betweenSections(),

          ///////////////////////////// PLAYLIST /////////////////////////////
          // [BEGIN] Playlists
          if (isPlaylistPage) const SliverGap.belowTop(),
          if (isPlaylistPage) const PlaylistView(),

          ///////////////////////////// HISTORY /////////////////////////////
          // [BEGIN] Playback History
          if (isHistoryPage)
            SliverToBoxAdapter(
              child: Card(
                margin: EdgeInsets.zero,
                child: PagePadding(
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
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          if (isHistoryPage)
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          if (isHistoryPage) const SectionTitle(title: 'Songs played recently'),
          if (isHistoryPage) const SliverPlaybackHistoryList(),
        ].mapIndexed((index, child) {
          if (index == 0 || index == 1) {
            return child;
          }

          return PagePadding(sliver: true, child: child);
        }).toList(),
      ),
    );
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
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text('View Details'),
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
