import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PlayingController extends GetxController {
  AudioPlayer player = AudioPlayer();

  PlayingController() {
    this.isPlaying.bindStream(player.playingStream);
    this.progress.bindStream(player.positionStream);
    this.buffered.bindStream(player.bufferedPositionStream);
    // FIXME: use duration in header
    this
        .duration
        .bindStream(player.durationStream.map((t) => t ?? Duration.zero));
  }

  Rx<bool> isPlaying = false.obs;

  Rx<Duration> progress = Duration.zero.obs;
  Rx<Duration> buffered = Duration.zero.obs;
  Rx<Duration> duration = Duration.zero.obs;

  Future<void> play() async {
    await player.play();
  }

  Future<void> pause() async {
    await player.pause();
  }

  Future<void> playOrPause() async {
    if (this.isPlaying.value) {
      await this.pause();
    } else {
      await this.play();
    }
  }

  Future<void> previous() async {
    await player.seekToPrevious();
  }

  Future<void> next() async {
    await player.seekToNext();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await player.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabledde(bool enable) async {
    await player.setShuffleModeEnabled(enable);
  }
}
