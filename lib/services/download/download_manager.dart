import 'package:annix/services/download/download_task.dart';
import 'package:flutter/material.dart';

class DownloadManager extends ChangeNotifier {
  final List<DownloadTask> tasks = [];

  DownloadTask add(DownloadTask task) {
    tasks.insert(0, task);
    notifyListeners();
    return task;
  }
}
