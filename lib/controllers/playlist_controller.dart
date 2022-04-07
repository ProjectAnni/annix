import 'package:annix/controllers/playing_controller.dart';
import 'package:annix/services/annil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlaylistController extends GetxController {
  PlayingController _playing = Get.find<PlayingController>();

  RxList<MediaItem> playlist = RxList();
  Rx<int> playingIndex = 0.obs;

  PlaylistController() {
    playingIndex
        .bindStream(_playing.player.currentIndexStream.map((t) => t ?? -1));
  }

  Future<void> setPlaylist(List<AnnilAudioSource> songs,
      {int? initialIndex}) async {
    await _playing.pause();
    await _playing.player.setAudioSource(
        ConcatenatingAudioSource(children: songs),
        initialIndex: initialIndex);
    await _playing.play();
    playlist.replaceRange(
        0, playlist.length, songs.map((e) => e.tag as MediaItem));
  }
}
