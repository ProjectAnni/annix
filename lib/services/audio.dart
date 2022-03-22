import 'dart:async';
import 'dart:math';

import 'package:annix/services/annil.dart';
import 'package:annix/widgets/repeat_button.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AnniPositionState {
  const AnniPositionState({
    required this.progress,
    required this.buffered,
    this.total,
  });

  final Duration progress;
  final Duration buffered;
  final Duration? total;
}

class AnniAudioService {
  AudioPlayer player = AudioPlayer();

  List<AnnilAudioSource> playlist = [];
  int _activeIndex = -1;
  AnnilAudioSource? get activeAudioSource =>
      _activeIndex >= 0 && playlist.length > _activeIndex
          ? playlist[_activeIndex]
          : null;
  ValueNotifier<int> playlistChangeNotifier = ValueNotifier<int>(-1);

  ValueNotifier<AnniPositionState> positionNotifier =
      ValueNotifier<AnniPositionState>(
    const AnniPositionState(
      progress: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );

  // Constructor
  AnniAudioService() {
    this.player.positionStream.listen((progress) {
      positionNotifier.value = AnniPositionState(
        progress: progress,
        buffered: positionNotifier.value.buffered,
        total: positionNotifier.value.total,
      );
    });

    this.player.bufferedPositionStream.listen((buffered) {
      positionNotifier.value = AnniPositionState(
        progress: positionNotifier.value.progress,
        buffered: buffered,
        total: positionNotifier.value.total,
      );
    });

    this.player.durationStream.listen((total) {
      positionNotifier.value = AnniPositionState(
        progress: positionNotifier.value.progress,
        buffered: positionNotifier.value.buffered,
        total: total,
      );
    });
  }

  bool initialized = false;
  // Initialize after construction, including async parts
  Future<void> init() async {
    if (this.activeAudioSource != null) {
      playlistChangeNotifier.value = _activeIndex;
      try {
        await this.player.setAudioSource(this.activeAudioSource!);
        if (!initialized) {
          this.player.playerStateStream.listen((event) {
            if (event.processingState == ProcessingState.completed) {
              this.next();
            }
          });
          initialized = true;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> previous() async {
    print(['prev', this._activeIndex, this.playlist.length]);
    if (this._activeIndex > 0 && this.playlist.isNotEmpty) {
      this._activeIndex--;
      await this.init();
    }
  }

  Future<void> next() async {
    print(['next', this._activeIndex, this.playlist.length]);
    if (this.repeatMode == RepeatMode.LoopOne) {
      await this.player.seek(Duration());
    } else if (this.repeatMode == RepeatMode.Random) {
      // shuffle
      var next = Random().nextInt(this.playlist.length);
      if (next != this._activeIndex) {
        this._activeIndex = next;
        await this.init();
      } else {
        await this.player.seek(Duration());
      }
    } else {
      // normal || loop
      if (this._activeIndex + 1 != this.playlist.length) {
        this._activeIndex++;
      } else if (this.repeatMode == RepeatMode.Loop) {
        this._activeIndex = 0;
      } else {
        await this.pause();
      }
      await this.init();
    }
  }

  Future<void> goto(int index) async {
    if (index >= 0 && index < this.playlist.length) {
      this._activeIndex = index;
      await this.init();
    }
  }

  Future<void> setPlaylist(List<AnnilAudioSource> songs) async {
    await this.clear();
    this.playlist.addAll(songs);
    if (this.playlist.isNotEmpty) {
      this._activeIndex = 0;
    }
    await this.init();
  }

  Future<void> play() async {
    await this.player.play();
  }

  Future<void> pause() async {
    await this.player.pause();
  }

  Future<void> clear() async {
    await this.pause();

    playlistChangeNotifier.value = -1;
    positionNotifier.value = AnniPositionState(
      progress: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    );

    this._activeIndex = -1;
    this.playlist.clear();
  }

  RepeatMode _repeatMode = RepeatMode.Normal;
  RepeatMode get repeatMode => _repeatMode;
  set repeatMode(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.Normal:
        player.setLoopMode(LoopMode.off);
        // player.setShuffleModeEnabled(false);
        break;
      case RepeatMode.Loop:
        player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.LoopOne:
        player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.Random:
        player.setLoopMode(LoopMode.all);
        // player.setShuffleModeEnabled(true);
        break;
    }
    _repeatMode = mode;
  }
}
