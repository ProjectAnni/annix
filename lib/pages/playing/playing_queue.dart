import 'package:annix/controllers/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingQueue extends StatelessWidget {
  const PlayingQueue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlayerController>(
      builder: (player) => ListView.builder(
        itemCount: player.queue.length,
        itemBuilder: (context, index) {
          var song = player.queue[index];
          return ListTile(
            leading: Text("${index + 1}"),
            title: Text('${song.track.title}', overflow: TextOverflow.ellipsis),
            trailing:
                player.playingIndex == index ? Icon(Icons.play_arrow) : null,
            minLeadingWidth: 16,
            onTap: () async {
              await player.jump(index);
            },
          );
        },
      ),
    );
  }
}
