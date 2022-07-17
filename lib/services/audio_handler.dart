import 'dart:io';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:mpris_service/mpris_service.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final PlayerController player = Get.find();
  final AnnilController annil = Get.find();
  final AnnivController anniv = Get.find();

  static Future<void> init() async {
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux) {
      if (Platform.isLinux) {
        AudioServicePlatform.instance = LinuxAudioService();
      }

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
          updatePosition: this.player.progress.value,
          queueIndex: this.player.playingIndex,
        ));

    final playing = this.player.playing;
    if (playing != null) {
      this.mediaItem.add(MediaItem(
            id: playing.id,
            title: playing.track.title,
            album: playing.track.disc.album.title,
            artist: playing.track.artist,
            duration: player.duration.value,
            artUri: CoverReverseProxy().url(
              CoverItem(
                uri: annil.clients.value.getCoverUrl(albumId: playing.albumId),
                albumId: playing.albumId,
                // discId: discId,
              ),
            ),
          ));
    }
  }
}

class LinuxAudioService extends AudioServicePlatform {
  final AnnixMPRISService mpris = AnnixMPRISService();
  final PlayerController player = Get.find();

  @override
  Future<void> configure(ConfigureRequest request) async {}

  @override
  Future<void> setState(SetStateRequest request) async {
    mpris.playbackStatus =
        request.state.playing ? PlaybackStatus.playing : PlaybackStatus.stopped;
    mpris.position = request.state.updatePosition;
  }

  @override
  Future<void> setQueue(SetQueueRequest request) async {}

  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    mpris.metadata = Metadata(
      trackId: "/${request.mediaItem.id.replaceAll('-', '')}",
      trackTitle: request.mediaItem.title,
      trackArtist: [request.mediaItem.artist!],
      artUrl: request.mediaItem.artUri.toString(),
      trackLength: request.mediaItem.duration,
      albumName: request.mediaItem.album!,
    );
  }

  @override
  Future<void> stopService(StopServiceRequest request) async {}

  @override
  Future<void> androidForceEnableMediaButtons(
      AndroidForceEnableMediaButtonsRequest request) async {}

  @override
  Future<void> notifyChildrenChanged(
      NotifyChildrenChangedRequest request) async {}

  @override
  Future<void> setAndroidPlaybackInfo(
      SetAndroidPlaybackInfoRequest request) async {}

  @override
  void setHandlerCallbacks(AudioHandlerCallbacks callbacks) {}
}

class AnnixMPRISService extends MPRISService {
  final PlayerController player = Get.find();

  AnnixMPRISService()
      : super(
          "annix",
          identity: "Annix",
          emitSeekedSignal: true,
          canPlay: true,
          canPause: true,
          canGoPrevious: true,
          canGoNext: true,
        );

  @override
  Future<void> onPlayPause() async {
    await player.playOrPause();
  }

  @override
  Future<void> onPlay() async {
    await player.play();
  }

  @override
  Future<void> onPause() async {
    await player.pause();
  }

  @override
  Future<void> onPrevious() async {
    await player.previous();
  }

  @override
  Future<void> onNext() async {
    await player.next();
  }
}
