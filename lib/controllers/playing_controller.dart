import 'package:annix/models/anniv.dart';
import 'package:get/get.dart';

enum PlayingStatus {
  loading,
  playing,
  paused,
}

class PlayingState {
  PlayingStatus status = PlayingStatus.paused;
  TrackInfoWithAlbum? track;
}

class PlayingController extends GetxController {
  Rx<PlayingState> state = PlayingState().obs;

  updateTrack(TrackInfoWithAlbum track) {
    this.state.update((state) {
      state?.track = track;
      state?.status = PlayingStatus.loading;
    });
  }

  stop() {
    this.state.update((state) {
      state?.track = null;
      state?.status = PlayingStatus.paused;
    });
  }
}
