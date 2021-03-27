import 'dart:convert';

import 'package:annix/services/audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist.dart';

class Global {
  static late SharedPreferences _preferences;

  static late Playlist playlist;

  static late AnniAudioPlayer player;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();

    String active = _preferences.getString("active_playlist") ?? "[]";
    playlist = Playlist.fromJson(jsonDecode(active));

    player = await AnniAudioPlayer.instance();
  }
}
