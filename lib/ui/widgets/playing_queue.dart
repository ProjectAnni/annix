import 'package:annix/services/playback/playback.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingQueue extends StatelessWidget {
  const PlayingQueue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaybackService>(
      builder: (context, player, child) => ListView.builder(
        controller: ScrollController(
            initialScrollOffset: 32.0 * (player.playingIndex ?? 0)),
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
