import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/anniv/anniv_model.dart';

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
