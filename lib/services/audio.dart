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
    if (this._activeIndex > 0 && this.playlist.isNotEmpty) {
      this._activeIndex--;
      await this.init();
    }
  }

  Future<void> next() async {
    if (this.repeatMode == RepeatMode.LoopOne) {
      await this.player.seek(null);
    } else if (this.repeatMode == RepeatMode.Random) {
      // shuffle
      var next = Random().nextInt(this.playlist.length);
      if (next != this._activeIndex) {
        this._activeIndex = next;
        await this.init();
      } else {
        await this.player.seek(null);
      }
    } else {
      // normal || loop
      if (this._activeIndex + 1 != this.playlist.length) {
        this._activeIndex++;
      } else if (this.repeatMode == RepeatMode.Loop) {
        this._activeIndex = 0;
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
        player.setShuffleModeEnabled(false);
        break;
      case RepeatMode.Loop:
        player.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.LoopOne:
        player.setLoopMode(LoopMode.one);
        break;
      case RepeatMode.Random:
        player.setLoopMode(LoopMode.all);
        player.setShuffleModeEnabled(true);
        break;
    }
    _repeatMode = mode;
  }
}

class AnnilPlaylist extends ChangeNotifier {
  final AnniAudioService _service;
  AnnilAudioSource? get playing => _service.activeAudioSource;

  List<AudioSource> get playlist => _service.playlist;

  String? get getPlayingAlbumId => playing?.albumId;
  int? get playingDiscID => playing?.discId;
  int? get playingTrackId => playing?.trackId;

  AnnilPlaylist({required AnniAudioService service}) : _service = service {
    _service.playlistChangeNotifier.addListener(() {
      notifyListeners();
    });
  }

  Future<void> goto(AudioSource audio) async {
    var index = playlist.indexOf(audio);
    if (index != -1) {
      await _service.goto(index);
    }
  }
}

class AnnilPlayState extends ChangeNotifier {
  final AnniAudioService _service;

  PlayerState state;

  AnnilPlayState({required AnniAudioService service})
      : _service = service,
        state = service.player.playerState {
    _service.player.playerStateStream.listen((state) {
      this.state = state;
      notifyListeners();
    });
  }
}
