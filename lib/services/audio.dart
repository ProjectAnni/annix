import 'package:annix/services/annil.dart';
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
    useLazyPreparation: false,
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
      await this.player.setAudioSource(this.playlist);
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
}

class AnnilPlaylist extends ChangeNotifier {
  final AnniAudioService _service;
  AnnilAudioSource? playing;

  String? get playingCatalog => playing?.catalog;
  int? get playingTrackId => playing?.trackId;
  int? get playingTrackIndex =>
      playingTrackId != null ? playingTrackId! - 1 : null;

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

  void triggerChange() {
    notifyListeners();
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
