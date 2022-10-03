String bytesToString(int bytes) {
  if (bytes < 0) {
    return '-';
  }

  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(2)} KiB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MiB';
  } else {
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GiB';
  }
}
