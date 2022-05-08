import 'package:annix/controllers/playing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlayingQueue extends StatelessWidget {
  const PlayingQueue({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayingController playing = Get.find();

    return Obx(
      () => ListView.builder(
        itemCount: playing.queue.length,
        itemBuilder: (context, index) {
          var song = playing.queue[index];
          return Obx(
            () => ListTile(
              leading: Text("${index + 1}"),
              title: Text('${song.title}', overflow: TextOverflow.ellipsis),
              trailing: playing.playingIndex.value == index
                  ? Icon(Icons.play_arrow)
                  : null,
              minLeadingWidth: 16,
              onTap: () async {
                await playing.jump(index);
              },
            ),
          );
        },
      ),
    );
  }
}
