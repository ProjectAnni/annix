import 'dart:async';

import 'package:annix/services/annil.dart';
import 'package:just_audio/just_audio.dart';

class AnniAudioService {
  AudioPlayer player = AudioPlayer();

  Future<void> previous() async {
    await this.player.seekToPrevious();
  }

  Future<void> next() async {
    await this.player.seekToNext();
  }

  Future<void> goto(int index) async {
    // TODO
    // await this.player.seekToNext()
    // if (index >= 0 && index < this.playlist.length) {
    //   this._activeIndex = index;
    //   await this.init();
    // }
  }

  Future<void> setPlaylist(List<AnnilAudioSource> songs,
      {int? initialIndex}) async {
    await this.pause();
    await this.player.setAudioSource(ConcatenatingAudioSource(children: songs),
        initialIndex: initialIndex);
    await this.play();
  }

  Future<void> play() async {
    await this.player.play();
  }

  Future<void> pause() async {
    await this.player.pause();
  }

  Future<void> clear() async {
    await this.pause();
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await player.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabledde(bool enable) async {
    await player.setShuffleModeEnabled(enable);
  }
}
