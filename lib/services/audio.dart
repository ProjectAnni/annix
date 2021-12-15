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
  ConcatenatingAudioSource playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    children: [],
  );

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
  Future<void> init({force = false}) async {
    if (!initialized || force) {
      try {
        await this.player.setAudioSource(this.playlist);
      } catch (e) {
        print(e);
      }
      initialized = true;
    }
  }

  Future<void> play() async {
    await this.init();
    await this.player.play();
  }

  Future<void> pause() async {
    await this.player.pause();
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
  AnnilAudioSource? playing;

  ConcatenatingAudioSource get playlist => _service.playlist;

  String? get getPlayingAlbumId => playing?.albumId;
  int? get playingDiscID => playing?.discId;
  int? get playingTrackId => playing?.trackId;

  AnnilPlaylist({required AnniAudioService service}) : _service = service {
    _service.player.currentIndexStream.listen((index) {
      if (index != null && service.playlist.length > index) {
        playing = service.playlist.children[index] as AnnilAudioSource;
      } else {
        playing = null;
      }
      notifyListeners();
    });
  }

  void resetPlaylist() {
    playing = _service.playlist.children.length > 0
        ? _service.playlist.children[0] as AnnilAudioSource
        : null;
    notifyListeners();
  }

  Future<void> goto(AudioSource audio) async {
    var index = playlist.children.indexOf(audio);
    if (index != -1) {
      return await _service.player.seek(Duration.zero, index: index);
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
