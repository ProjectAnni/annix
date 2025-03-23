import 'package:annix/providers.dart';
import 'package:annix/ui/page/album.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/gaps.dart';
import 'package:annix/ui/widgets/section_title.dart';
import 'package:annix/ui/widgets/shimmer/shimmer_text.dart';
import 'package:annix/ui/widgets/text/text.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyMusicPage extends StatelessWidget {
  const EmptyMusicPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_off,
            size: 64,
            color: context.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No track playing',
            style: context.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a track to start playing',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class MusicPage extends HookConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bodyFocusNode = useFocusNode();
    final searchController = useSearchController();

    final hasTrack = ref.watch(playingProvider.select((s) => s.source != null));

    return Material(
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              // https://github.com/flutter/flutter/issues/138099#issuecomment-1992390262
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: FocusScope(
                  onFocusChange: (value) {
                    if (value) {
                      bodyFocusNode.requestFocus();
                    }
                  },
                  child: SearchAnchor.bar(
                    searchController: searchController,
                    barLeading: const Icon(Icons.search),
                    barHintText: 'Search your library',
                    barElevation: WidgetStateProperty.all(0),
                    suggestionsBuilder: (context, controller) {
                      return [
                        ListTile(
                          leading: const Icon(Icons.label),
                          title: const Text('By Tags'),
                          onTap: () {
                            searchController.closeView('');
                            context.push('/tags');
                          },
                        )
                      ];
                    },
                    onSubmitted: (value) {
                      searchController.closeView('');
                      context.push('/search', extra: value);
                    },
                    viewHintText: 'Tracks, albums, artists, and more',
                  ),
                ),
                expandedTitleScale: 1,
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    return PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      menuPadding: const EdgeInsets.symmetric(horizontal: 0),
                      position: PopupMenuPosition.under,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: () {
                            ref
                                .read(sleepTimerProvider.notifier)
                                .toggle(context);
                          },
                          child: Consumer(
                            builder: (context, ref, child) {
                              final controller = ref.watch(sleepTimerProvider);
                              return Row(
                                spacing: 8.0,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.enabled
                                      ? Icon(
                                          Icons.check_circle,
                                          color: context.colorScheme.primary,
                                        )
                                      : const Icon(Icons.timer_outlined),
                                  const Text('Sleep Timer'),
                                ],
                              );
                            },
                          ),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await ref.read(endlessModeProvider).toggle(context);
                          },
                          child: Consumer(
                            builder: (context, ref, child) {
                              final controller = ref.watch(endlessModeProvider);
                              return Row(
                                spacing: 8.0,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.enabled
                                      ? Icon(
                                          Icons.check_circle,
                                          color: context.colorScheme.primary,
                                        )
                                      : const Icon(Icons.repeat),
                                  const Text('Endless Mode'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          ];
        },
        body: Focus(
          focusNode: bodyFocusNode,
          child: hasTrack
              ? CustomScrollView(
                  slivers: [
                    SliverGap.betweenSections(),
                    NowPlayingCard(),
                    SliverGap.betweenSections(),
                    SectionTitle(title: 'Next songs'),
                    NextPlayingQueue(),
                  ].map((e) => PagePadding(sliver: true, child: e)).toList(),
                )
              : const EmptyMusicPage(),
        ),
      ),
    );
  }
}

class CommonPlayingTrackCard extends ConsumerWidget {
  final Widget cover;
  final Widget title;
  final Widget subtitle;
  final VoidCallback? onTap;
  final Color? color;

  final double? elevation;
  final EdgeInsets margin;
  final Widget? trailing;

  const CommonPlayingTrackCard({
    super.key,
    required this.cover,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.color,
    this.elevation,
    this.margin = EdgeInsets.zero,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      elevation: elevation,
      clipBehavior: Clip.hardEdge,
      margin: margin,
      color: color,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: cover,
        title: title,
        subtitle: subtitle,
        onTap: onTap,
        trailing: trailing,
      ),
    );
  }
}

class ShimmerPlayingTrackCard extends StatelessWidget {
  final Widget cover;

  const ShimmerPlayingTrackCard({super.key, required this.cover});

  @override
  Widget build(BuildContext context) {
    return CommonPlayingTrackCard(
      cover: cover,
      title: ShimmerText(length: 8),
      subtitle: ShimmerText(length: 20),
    );
  }
}

class NowPlayingCard extends ConsumerWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final delegate = ref.watch(routerProvider);
    final player = ref.watch(playbackProvider);

    if (player.playing.source == null) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('No playing song'),
        ),
      );
    }

    final playing = player.queue[player.playingIndex!];
    final track = ref.watch(trackFamily(playing.identifier));

    return SliverToBoxAdapter(
      child: track.when(
        data: (track) => CommonPlayingTrackCard(
          cover: PlayingMusicCover(),
          title: Text(
            track.title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          subtitle: AlbumTitleText(title: track.disc.album.title),
          onTap: delegate.openPanel,
          color: context.colorScheme.primaryContainer,
        ),
        error: (error, stacktrace) => const Text('Error'),
        loading: () => ShimmerPlayingTrackCard(cover: PlayingMusicCover()),
      ),
    );
  }
}

class NextPlayingQueue extends ConsumerWidget {
  const NextPlayingQueue({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final player = ref.watch(playbackProvider);
    final playingQueue = player.queue;
    final playingIndex = player.playingIndex;

    if (playingQueue.isEmpty || playingIndex == null) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('No active playing'),
        ),
      );
    }

    return SliverReorderableList(
      onReorder: (int oldIndex, int newIndex) {
        player.reorderQueue(
          playingIndex + oldIndex + 1,
          playingIndex + newIndex + 1,
        );
      },
      itemCount: player.queue.length - playingIndex - 1,
      itemBuilder: (context, index) {
        final actualIndex = playingIndex + index + 1;
        final song = player.queue[actualIndex];
        final key = ValueKey('$index/${song.id}');

        late final Widget trailing;
        if (context.isDesktop) {
          trailing = MenuAnchor(
            alignmentOffset: const Offset(-100, -40),
            builder: (context, controller, child) {
              return IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.play_arrow_outlined),
                child: Text('Play'),
                onPressed: () {
                  player.jump(actualIndex);
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.delete_outline),
                child: Text('Remove'),
                onPressed: () {
                  player.remove(actualIndex);
                },
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.upload),
                child: Text('Move to top'),
                onPressed: () {
                  player.reorderQueue(actualIndex, playingIndex + 1);
                },
              ),
            ],
          );
        } else {
          trailing = ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.drag_handle),
            ),
          );
        }

        final child = HookBuilder(
          builder: (context) {
            final isDuringDismiss = useState(false);
            return Dismissible(
              key: ValueKey(index),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                // do not allow the first song to be moved to the first
                if (direction == DismissDirection.startToEnd &&
                    actualIndex == playingIndex + 1) {
                  return false;
                }
                return true;
              },
              onDismissed: (direction) {
                switch (direction) {
                  case DismissDirection.endToStart:
                    // delete
                    player.remove(actualIndex);
                    break;
                  case DismissDirection.startToEnd:
                    // make this track play next
                    player.reorderQueue(actualIndex, playingIndex + 1);
                    break;
                  default:
                    break;
                }
              },
              onUpdate: (details) {
                if (details.progress > 0) {
                  isDuringDismiss.value = true;
                } else {
                  isDuringDismiss.value = false;
                }
              },
              background: Container(
                color: Colors.transparent,
                alignment: Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Row(
                    spacing: 8.0,
                    children: [
                      Icon(Icons.swipe_up_outlined),
                      Text('Move to top'),
                    ],
                  ),
                ),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                child: const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.delete_outline),
                ),
              ),
              child: Consumer(builder: (context, ref, child) {
                final track = ref.watch(trackFamily(song.identifier));
                final cover = CoverCard(
                  child: MusicCover.fromAlbum(albumId: song.identifier.albumId),
                );

                return track.when(
                  data: (track) => CommonPlayingTrackCard(
                    elevation: isDuringDismiss.value ? 2 : 0,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: context.colorScheme.surfaceContainer,
                    cover: cover,
                    title: Text(
                      track.title,
                      style: context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: AlbumTitleText(title: track.disc.album.title),
                    onTap: () async {
                      if (!context.isDesktop) {
                        await player.jump(actualIndex);
                      }
                    },
                    trailing: trailing,
                  ),
                  error: (error, stacktrace) => const Text('Error'),
                  loading: () => ShimmerPlayingTrackCard(cover: cover),
                );
              }),
            );
          },
        );
        if (context.isDesktop) {
          return ReorderableDragStartListener(
            index: index,
            key: key,
            child: child,
          );
        } else {
          return ReorderableDelayedDragStartListener(
            index: index,
            key: key,
            child: child,
          );
        }
      },
    );
  }
}
