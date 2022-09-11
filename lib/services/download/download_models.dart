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
