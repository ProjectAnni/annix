import 'dart:io';

import 'package:annix/controllers/annil_controller.dart';
import 'package:annix/controllers/anniv_controller.dart';
import 'package:annix/controllers/player_controller.dart';
import 'package:annix/pages/playing/playing_mobile.dart';
import 'package:annix/widgets/cover_image.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:anni_mpris_service/anni_mpris_service.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final PlayerController player = Get.find();
  final AnnilController annil = Get.find();
  final AnnivController anniv = Get.find();

  static Future<void> init() async {
    if (Platform.isLinux) {
      AudioServicePlatform.instance = LinuxAudioService();
    }

    final service = await AudioService.init(
      builder: () => AnnixAudioHandler._(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'rs.anni.annix.audio',
        androidNotificationChannelName: 'Annix Audio playback',
        androidNotificationIcon: 'drawable/ic_notification',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        artDownscaleHeight: 300,
        artDownscaleWidth: 300,
        preloadArtwork: true,
      ),
    );

    AudioSession.instance.then((session) async {
      // configure
      await session.configure(AudioSessionConfiguration.music());

      // unplugged
      session.becomingNoisyEventStream.listen((_) => service.pause());
      // interruption
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // TODO: duck
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              service.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // TODO: unduck
              break;
            case AudioInterruptionType.pause:
              service.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    });

    AudioService.notificationClicked.listen((clicked) {
      if (clicked) {
        Get.to(() => PlayingMobileScreen());
      }
    });
  }

  AnnixAudioHandler._() {
    this.player.addListener(() => this._updatePlaybackState());
    this.player.playerStatus.listen((_) => this._updatePlaybackState());
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
    final isPlaying = this.player.playerStatus.value == PlayerStatus.playing;
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
            PlayerStatus.playing: AudioProcessingState.ready,
            PlayerStatus.stopped: AudioProcessingState.idle,
            PlayerStatus.paused: AudioProcessingState.ready,
            PlayerStatus.buffering: AudioProcessingState.buffering,
          }[this.player.playerStatus.value]!,
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
          canSeek: true,
          supportLoopStatus: true,
          supportShuffle: true,
        ) {
    player.loopMode.listen((loopMode) {
      switch (loopMode) {
        case LoopMode.off:
          this.loopStatus = LoopStatus.none;
          this.shuffle = false;
          break;
        case LoopMode.all:
          this.loopStatus = LoopStatus.playlist;
          this.shuffle = false;
          break;
        case LoopMode.one:
          this.loopStatus = LoopStatus.track;
          this.shuffle = false;
          break;
        case LoopMode.random:
          this.loopStatus = LoopStatus.playlist;
          this.shuffle = true;
          break;
      }
    });
  }

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

  @override
  Future<void> onSeek(int offset) async {
    await player.seek(player.progress.value + Duration(microseconds: offset));
  }

  @override
  Future<void> onSetPosition(String trackId, int position) async {
    await player.seek(Duration(microseconds: position));
  }

  @override
  Future<void> onLoopStatus(LoopStatus loopStatus) async {
    switch (loopStatus) {
      case LoopStatus.none:
        await player.setLoopMode(LoopMode.off);
        break;
      case LoopStatus.track:
        await player.setLoopMode(LoopMode.one);
        break;
      case LoopStatus.playlist:
        await player.setLoopMode(LoopMode.all);
        break;
    }
    this.loopStatus = loopStatus;
  }

  @override
  Future<void> onShuffle(bool shuffle) async {
    if (shuffle) {
      await player.setLoopMode(LoopMode.random);
    } else {
      switch (this.loopStatus) {
        case LoopStatus.none:
          await player.setLoopMode(LoopMode.off);
          break;
        case LoopStatus.track:
          await player.setLoopMode(LoopMode.one);
          break;
        case LoopStatus.playlist:
          await player.setLoopMode(LoopMode.all);
          break;
      }
    }
    this.shuffle = shuffle;
  }
}
