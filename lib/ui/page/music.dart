import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/gaps.dart';
import 'package:annix/ui/widgets/section_title.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: SearchAnchor.bar(
          searchController: searchController,
          barLeading: const Icon(Icons.search),
          barHintText: 'Search your library',
          barElevation: WidgetStateProperty.all(0),
          suggestionsBuilder: (context, controller) {
            return [
              ListTile(
                leading: Icon(Icons.history),
                title: Text('history 1'),
              )
            ];
          },
          onSubmitted: (value) {
            bodyFocusNode.requestFocus();
            searchController.closeView('');
            context.push('/search', extra: value);
          },
          viewHintText: 'Tracks, albums, artists, and more',
          viewLeading: BackButton(
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              context.pop();
              bodyFocusNode.requestFocus();
            },
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(8.0),
          child: SizedBox(),
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
                      ref.read(sleepTimerProvider.notifier).toggle(context);
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
      ),
      body: hasTrack
          ? Focus(
              focusNode: bodyFocusNode,
              child: const PagePadding(
                child: CustomScrollView(
                  slivers: [
                    SliverGap.belowTop(),
                    NowPlayingCard(),
                    SliverGap.betweenSections(),
                    SectionTitle(title: 'Next songs'),
                    NextPlayingQueue(),
                  ],
                ),
              ),
            )
          : const EmptyMusicPage(),
    );
  }
}

class NowPlayingCard extends ConsumerWidget {
  const NowPlayingCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final delegate = ref.watch(routerProvider);
    final player = ref.watch(playbackProvider);

    if (player.playingIndex == null) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('No playing song'),
        ),
      );
    }

    final playing = player.queue[player.playingIndex!];

    return SliverToBoxAdapter(
      child: Card(
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        color: context.colorScheme.primaryContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: CoverCard(
            child: MusicCover.fromAlbum(albumId: playing.identifier.albumId),
          ),
          title: Text(
            playing.track.title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onTertiaryContainer,
            ),
          ),
          subtitle: AlbumTitleText(title: playing.track.albumTitle),
          onTap: delegate.openPanel,
        ),
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
        return ReorderableDelayedDragStartListener(
          index: index,
          key: ValueKey('$index/${song.id}'),
          child: HookBuilder(builder: (context) {
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
              child: Card(
                elevation: isDuringDismiss.value ? 2 : 0,
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: CoverCard(
                    child:
                        MusicCover.fromAlbum(albumId: song.identifier.albumId),
                  ),
                  title: Text(
                    song.track.title,
                    style: context.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: AlbumTitleText(title: song.track.albumTitle),
                  onTap: () async {
                    await player.jump(actualIndex);
                  },
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
