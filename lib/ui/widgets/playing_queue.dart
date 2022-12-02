import 'package:annix/services/playback/playback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingQueue extends StatelessWidget {
  final ScrollController controller;

  const PlayingQueue({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackService>(
      builder: (context, player, child) => ListView.builder(
        shrinkWrap: true,
        controller: controller,
        itemCount: player.queue.length,
        itemBuilder: (context, index) {
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
      ),
    );
  }
}
