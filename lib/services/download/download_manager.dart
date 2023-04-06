import 'package:annix/services/download/download_task.dart';
import 'package:flutter/material.dart';
import 'package:pool/pool.dart';

class DownloadManager extends ChangeNotifier {
  final List<DownloadTask> tasks = [];
  final Pool pool = Pool(3);

  DownloadTask add(final DownloadTask task) {
    tasks.insert(0, task);
    notifyListeners();
    return task;
  }

  Future<void> addAll(final List<DownloadTask> tasks) async {
    this.tasks.insertAll(0, tasks);
    notifyListeners();

    for (final task in tasks) {
      pool.withResource(() => task.start());
    }
  }
}
