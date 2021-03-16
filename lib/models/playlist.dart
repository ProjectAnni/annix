import 'dart:collection';

import 'package:annix/models/song.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/foundation.dart';

enum RepeatMode {
  Normal,
  Random,
  LoopOne,
  Loop,
}

class Playlist {
  final List<Song> _songs;

  UnmodifiableListView<Song> get songs => UnmodifiableListView(_songs);

  Playlist.fromJson(List<dynamic> json)
      : _songs = json.map((e) => Song.fromJson(e)).toList();

  void add(Song song) {
    _songs.add(song);
  }

  void removeAll() {
    _songs.clear();
  }
}

class ActivePlaylist extends ChangeNotifier {
  RepeatMode _mode = RepeatMode.Random;
  RepeatMode get mode => _mode;

  int _current = -1;
  Song get song => Global.playlist._songs[_current];

  void add(Song song) {
    Global.playlist.add(song);
    notifyListeners();
  }

  void removeAll() {
    Global.playlist.removeAll();
    notifyListeners();
  }

  void setMode(RepeatMode mode) {
    _mode = mode;
    notifyListeners();
  }
}
