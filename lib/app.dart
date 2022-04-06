import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/controllers/playlist_controller.dart';
import 'package:annix/pages/root.dart';
import 'package:annix/services/global.dart';
import 'package:annix/pages/search.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnixApp extends StatelessWidget {
  const AnnixApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PlayingController(service: Global.audioService));
    Get.put(Global.annil);
    Get.put(PlaylistController(service: Global.audioService));

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Color.fromARGB(255, 184, 253, 127),
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => RootScreen(),
          binding: RootScreenBinding(),
        ),
        GetPage(
          name: '/search',
          page: () => SearchScreen(),
        ),
      ],
    );
  }
}

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PlayingController playing = Get.find();
    final AnnilController annil = Get.find();

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        double sensitivity = 360;

        print(details.primaryVelocity);
        if (details.primaryVelocity! > sensitivity) {
          // Right Swipe, prev
          print("Right Swipe, prev");
          playing.service.previous();
        } else if (details.primaryVelocity! < -sensitivity) {
          // Left Swipe, next
          print("Left Swipe, next");
          playing.service.next();
        }
      },
      child: Container(
        height: 64,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Obx(
              () => annil.cover(
                  albumId: playing.state.value.track?.track.albumId ?? "TODO"),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Obx(
                () => Text(
                  "${playing.state.value.track?.info.title}",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            RepeatButton(
              initial: Global.audioService.repeatMode,
              onRepeatModeChange: (mode) {
                Global.audioService.repeatMode = mode;
              },
            ),
            Obx(
              () => playing.status.value == PlayingStatus.loading
                  ? CircularProgressIndicator()
                  : IconButton(
                      icon: Icon(playing.status.value == PlayingStatus.playing
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () async {
                        if (playing.status.value == PlayingStatus.playing) {
                          playing.service.pause();
                        } else {
                          playing.service.play();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
