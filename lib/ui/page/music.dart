import 'package:annix/providers.dart';
import 'package:annix/ui/widgets/cover.dart';
import 'package:annix/ui/widgets/gaps.dart';
import 'package:annix/ui/widgets/playback/endless_mode.dart';
import 'package:annix/ui/widgets/playback/sleep_timer.dart';
import 'package:annix/ui/widgets/section_title.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MusicPage extends HookConsumerWidget {
  const MusicPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final bodyFocusNode = useFocusNode();
    final searchController = useSearchController();

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
        elevation: 0,
      ),
      body: Focus(
        focusNode: bodyFocusNode,
        child: PagePadding(
          child: CustomScrollView(
            slivers: [
              const SliverGap.belowTop(),
              const SliverToBoxAdapter(
                child: OverflowBar(
                  spacing: 8.0,
                  children: [
                    EndlessModeChip(),
                    SleepTimerChip(),
                  ],
                ),
              ),
              SectionTitle(
                title: 'Playing',
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const NowPlayingCard(),
              const SliverGap.betweenSections(),
              const SectionTitle(title: 'Next songs'),
              const NextPlayingQueue(),
            ],
          ),
        ),
      ),
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
        color: context.colorScheme.tertiaryContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: CoverCard(
            child: MusicCover.fromAlbum(albumId: playing.identifier.albumId),
          ),
          title: Text(
            playing.track.title,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onTertiaryContainer,
            ),
          ),
          subtitle: Text(
            playing.track.albumTitle,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onTertiaryContainer,
            ),
          ),
          onTap: () {
            delegate.openPanel();
          },
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
                  child: Icon(Icons.swipe_up_outlined),
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
                elevation: isDuringDismiss.value ? 8 : 0,
                color: context.colorScheme.secondaryContainer,
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
                  ),
                  subtitle: Text(
                    song.track.albumTitle,
                    style: context.textTheme.labelMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
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
