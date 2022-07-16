import 'dart:io';

import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final PlayerController player = Get.find();
  final AnnivController anniv = Get.find();

  static Future<void> init() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await AudioService.init(
        builder: () => AnnixAudioHandler._(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'rs.anni.annix.audio',
          androidNotificationChannelName: 'Annix Audio playback',
          androidNotificationIcon: 'drawable/ic_notification',
          androidNotificationOngoing: true,
          artDownscaleHeight: 300,
          artDownscaleWidth: 300,
          preloadArtwork: true,
        ),
      );

      AudioService.notificationClicked.listen((clicked) {
        if (clicked) {
          Get.toNamed('/playing');
        }
      });
    }
  }

  AnnixAudioHandler._() {
    this.player.addListener(() => this._updatePlaybackState());
    this.player.playerState.listen((_) => this._updatePlaybackState());
    this.player.progress.listen((_) => this._updatePlaybackState());
    this.anniv.favorites.listen((_) => this._updatePlaybackState());
  }

  Future<void> play() async {
    return this.player.play();
  }

  Future<void> pause() {
    return this.player.pause();
  }

  Future<void> stop() {
    return this.player.stop();
  }

  Future<void> seek(Duration position) {
    return this.player.seek(position);
  }

  @override
  Future<void> skipToNext() {
    return this.player.next();
  }

  @override
  Future<void> skipToPrevious() {
    return this.player.previous();
  }

  @override
  Future<void> fastForward() async {
    final id = this.player.playing?.identifier;
    if (id != null) {
      await anniv.toggleFavorite(id);
    }
  }

  void _updatePlaybackState() {
    final isPlaying = this.player.playerState.value == PlayerState.playing;
    final hasPrevious = (this.player.playingIndex ?? 0) > 0;
    final hasNext = (this.player.playingIndex ?? this.player.queue.length) <
        this.player.queue.length - 1;
    final isFavorited = this.player.playing != null &&
        anniv.favorites.containsKey(this.player.playing!.id);

    final controls = [
      isFavorited
          ? MediaControl(
              label: 'Unfavorite',
              androidIcon: 'drawable/ic_favorite',
              action: MediaAction.fastForward,
            )
          : MediaControl(
              label: 'Favorite',
              androidIcon: 'drawable/ic_favorite_border',
              action: MediaAction.fastForward,
            ),
      if (hasPrevious) MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
      if (hasNext) MediaControl.skipToNext,
    ];

    this.playbackState.add(playbackState.value.copyWith(
          controls: controls,
          androidCompactActionIndices: List.generate(controls.length, (i) => i)
              .where((i) =>
                  controls[i].action == MediaAction.fastForward ||
                  controls[i].action == MediaAction.pause ||
                  controls[i].action == MediaAction.play)
              .toList(),
          systemActions: {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          processingState: {
            PlayerState.playing: AudioProcessingState.ready,
            PlayerState.stopped: AudioProcessingState.idle,
            PlayerState.paused: AudioProcessingState.ready,
            PlayerState.completed: AudioProcessingState.completed,
          }[this.player.playerState.value]!,
          playing: isPlaying,
          // updatePosition: this.player.progress.value,
          queueIndex: this.player.playingIndex,
        ));

    final playing = this.player.playing;
    if (playing != null) {
      this.mediaItem.add(MediaItem(
            id: playing.id,
            title: playing.track.title,
            album: playing.track.disc.album.title,
            artist: playing.track.artist,
          ));
    }
  }
}
