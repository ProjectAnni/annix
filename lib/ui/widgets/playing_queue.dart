import 'package:annix/providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayingQueue extends ConsumerWidget {
  final ScrollController controller;

  const PlayingQueue({super.key, required this.controller});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final player = ref.watch(playbackProvider);
    return ListView.builder(
      shrinkWrap: true,
      controller: controller,
      itemCount: player.queue.length,
      itemBuilder: (final context, final index) {
        final song = player.queue[index];
        return ListTile(
          leading: Text('${index + 1}'),
          title: Text(song.track.title, overflow: TextOverflow.ellipsis),
          minLeadingWidth: 16,
          selected: player.playingIndex == index,
          onTap: () async {
            await player.jump(index);
          },
          dense: true,
          trailing: IconButton(
            icon: const Icon(Icons.playlist_remove),
            onPressed: () {
              player.remove(index);
            },
          ),
        );
      },
    );
  }
}
