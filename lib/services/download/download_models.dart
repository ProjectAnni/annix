import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum DownloadCategory {
  audio,
  cover,
  database,
}

enum DownloadTaskStatus {
  downloading,
  paused,
  completed,
  failed,
}

class DownloadState extends StateNotifier<DownloadProgress> {
  DownloadState(super.state);

  update(final DownloadProgress newState) {
    state = newState;
  }

  int get current => state.current;
  int? get total => state.total;
}

class DownloadProgress {
  final int current;
  final int? total;

  // final int speed;

  const DownloadProgress({
    required this.current,
    this.total,
    // required this.speed,
  });
}

class DownloadTaskData {
  const DownloadTaskData();
}

class TrackDownloadTaskData extends DownloadTaskData {
  final TrackInfoWithAlbum info;
  final PreferQuality quality;

  TrackDownloadTaskData({required this.info, required this.quality});
}
