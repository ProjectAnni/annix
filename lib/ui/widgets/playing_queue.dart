import 'package:annix/services/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayingQueue extends StatelessWidget {
  const PlayingQueue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, player, child) => ListView.builder(
        controller: ScrollController(
            initialScrollOffset: 32.0 * (player.playingIndex ?? 0)),
        itemCount: player.queue.length,
        itemBuilder: (context, index) {
          var song = player.queue[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text(song.track.title, overflow: TextOverflow.ellipsis),
            minLeadingWidth: 16,
            selected: player.playingIndex == index,
            onTap: () async {
              await player.jump(index);
            },
            dense: true,
          );
        },
      ),
    );
  }
}
