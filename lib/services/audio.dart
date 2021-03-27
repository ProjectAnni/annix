import 'dart:io';

import 'package:annix/services/platform.dart';
import 'package:audio_service/audio_service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dart_vlc/dart_vlc.dart';

class AnniAudioPlayer {
  late final Future<Player> _playerFuture;
  late Player _player;
  static int _playerId = 0;
  static AnniAudioPlayer? _instance;

  static Future<AnniAudioPlayer> instance() async {
    if (_instance == null) {
      _instance = AnniAudioPlayer._();
      await _instance!._prepare();
    }
    return _instance!;
  }

  AnniAudioPlayer._() {
    if (AnniPlatform.isSupportedDesktop) {
      _playerFuture =
          Player.create(id: _playerId++).then((value) => _player = value);
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      //
    }
  }

  _prepare() async {
    if (AnniPlatform.isSupportedDesktop) {
      await _playerFuture;
      _player.add(await Media.file(File(
          "/home/yesterday17/音乐/[A] 夏川椎菜/[200909][SMCL-647] アンチテーゼ/01. アンチテーゼ.flac")));
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      //
    }
  }

  get isPlaying => _player.playback.isPlaying;

  play() {
    if (AnniPlatform.isSupportedDesktop) {
      _player.play();
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      AudioService.play();
    }
  }

  pause() {
    if (AnniPlatform.isSupportedDesktop) {
      _player.pause();
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      AudioService.pause();
    }
  }

  stop() {
    if (AnniPlatform.isSupportedDesktop) {
      _player.stop();
    } else if (AnniPlatform.isSupportedMobile || AnniPlatform.isWeb) {
      AudioService.stop();
    }
  }
}
