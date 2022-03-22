import 'package:annix/models/anniv.dart';
import 'package:annix/services/audio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

enum PlayingStatus {
  loading,
  playing,
  paused,
}

class PlayingState {
  TrackInfoWithAlbum? track;
}

class PlayingController extends GetxController {
  final AnniAudioService service;

  PlayingController({required this.service}) {
    service.player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          this.status.value = PlayingStatus.paused;
          break;
        case ProcessingState.loading:
          // this.status.value = PlayingStatus.loading;
          break;
        case ProcessingState.buffering:
          // this.status.value = PlayingStatus.loading;
          break;
        case ProcessingState.ready:
        case ProcessingState.completed:
          if (state.playing) {
            this.status.value = PlayingStatus.playing;
          } else {
            this.status.value = PlayingStatus.paused;
          }
          break;
      }
      print(this.status.value);
      this.status.refresh();
    });
  }

  Rx<PlayingStatus> status = PlayingStatus.paused.obs;
  Rx<PlayingState> state = PlayingState().obs;

  updateTrack(TrackInfoWithAlbum? track) {
    this.state.update((state) {
      state?.track = track;
    });
    if (track != null) {
      status.value = PlayingStatus.loading;
    } else {
      status.value = PlayingStatus.paused;
    }
  }
}
