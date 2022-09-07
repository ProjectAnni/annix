import 'dart:io';

import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/global.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/local/database.dart';
import 'package:annix/services/player.dart';
import 'package:annix/services/annil/cover.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_session/audio_session.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:anni_mpris_service/anni_mpris_service.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final PlayerService player;

  final AnnivService anniv;
  final LocalDatabase database;

  List<Favorite> _favorites = [];

  static Future<void> init(BuildContext context) async {
    if (Platform.isLinux) {
      AudioServicePlatform.instance = LinuxAudioService(context);
    }

    final service = await AudioService.init(
      builder: () => AnnixAudioHandler._(context),
      config: const AudioServiceConfig(
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
      session.configure(const AudioSessionConfiguration.music());

      // unplugged
      session.becomingNoisyEventStream.listen((_) => service.pause());

      bool pausedByInterrupt = false;
      // interruption
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // TODO
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pausedByInterrupt = true;
              service.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
            // TODO
              break;
            case AudioInterruptionType.pause:
              if (pausedByInterrupt) {
                pausedByInterrupt = false;
                service.play();
              }
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    });

    AudioService.notificationClicked.listen((clicked) {
      if (clicked) {
        Global.mobileWeSlideController.show();
      }
    });
  }

  AnnixAudioHandler._(BuildContext context)
      : player = context.read(),
        anniv = context.read(),
        database = context.read() {
    player.addListener(() => _updatePlaybackState());
    database.favorites
        .select()
        .watch()
        .listen((favorites) => _updatePlaybackState(favorites));
  }

  @override
  Future<void> play() async {
    return player.play();
  }

  @override
  Future<void> pause() {
    return player.pause();
  }

  @override
  Future<void> stop() {
    return player.stop();
  }

  @override
  Future<void> seek(Duration position) {
    return player.seek(position);
  }

  @override
  Future<void> skipToNext() {
    return player.next();
  }

  @override
  Future<void> skipToPrevious() {
    return player.previous();
  }

  @override
  Future<void> fastForward() async {
    final track = player.playing?.track;
    if (track != null) {
      await anniv.toggleFavorite(track);
    }
  }

  void _updatePlaybackState([List<Favorite>? favorites]) {
    if (favorites != null) {
      _favorites = favorites;
    }

    final isPlaying = player.playerStatus == PlayerStatus.playing;
    final hasPrevious = (player.playingIndex ?? 0) > 0;
    final hasNext =
        (player.playingIndex ?? player.queue.length) < player.queue.length - 1;
    final isFavorite = player.playing != null &&
        _favorites.firstWhereOrNull(
              (f) =>
                  player.playing!.track.id ==
                  TrackIdentifier(
                    albumId: f.albumId,
                    discId: f.discId,
                    trackId: f.trackId,
                  ),
            ) !=
            null;

    final controls = [
      isFavorite
          ? const MediaControl(
              label: 'Unfavorite',
              androidIcon: 'drawable/ic_favorite',
              action: MediaAction.fastForward,
            )
          : const MediaControl(
              label: 'Favorite',
              androidIcon: 'drawable/ic_favorite_border',
              action: MediaAction.fastForward,
            ),
      if (hasPrevious) MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
      if (hasNext) MediaControl.skipToNext,
    ];

    playbackState.add(playbackState.value.copyWith(
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
      }[player.playerStatus]!,
      playing: isPlaying,
      updatePosition: player.position,
      queueIndex: player.playingIndex,
    ));

    final playing = player.playing;
    if (playing != null) {
      mediaItem.add(MediaItem(
        id: playing.id,
        title: playing.track.title,
        album: playing.track.albumTitle,
        artist: playing.track.artist,
        duration: player.duration,
        artUri: CoverReverseProxy().url(
          CoverItem(
            albumId: playing.identifier.albumId,
            // discId: playing.discId,
          ),
        ),
      ));
    }
  }
}

class LinuxAudioService extends AudioServicePlatform {
  final AnnixMPRISService mpris;
  bool seekOnNextUpdate = false;

  LinuxAudioService(BuildContext context) : mpris = AnnixMPRISService(context);

  @override
  Future<void> configure(ConfigureRequest request) async {}

  @override
  Future<void> setState(SetStateRequest request) async {
    mpris.playbackStatus =
        request.state.playing ? PlaybackStatus.playing : PlaybackStatus.stopped;
    mpris.updatePosition(request.state.updatePosition,
        forceEmitSeeked: seekOnNextUpdate);
    seekOnNextUpdate = false;
  }

  @override
  Future<void> setQueue(SetQueueRequest request) async {}

  @override
  Future<void> setMediaItem(SetMediaItemRequest request) async {
    final duration = request.mediaItem.duration;
    if (duration != null && duration > Duration.zero) {
      final trackId = "/${request.mediaItem.id.replaceAll('-', '')}";
      // if duration has changed on one track, clients may set current position to zero
      // so we need to `seek` to the correct position at next update
      seekOnNextUpdate = mpris.metadata.trackId == trackId &&
          mpris.metadata.trackLength != duration;

      mpris.metadata = Metadata(
        trackId: trackId,
        trackTitle: request.mediaItem.title,
        trackArtist: [request.mediaItem.artist!],
        artUrl: request.mediaItem.artUri.toString(),
        trackLength: duration,
        albumName: request.mediaItem.album!,
      );
    }
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
  final PlayerService player;

  AnnixMPRISService(BuildContext context)
      : player = Provider.of<PlayerService>(context, listen: false),
        super(
        "annix",
          identity: "Annix",
          emitSeekedSignal: false,
          canPlay: true,
          canPause: true,
          canGoPrevious: true,
          canGoNext: true,
          canSeek: true,
          supportLoopStatus: true,
          supportShuffle: true,
        ) {
    player.addListener(() {
      switch (player.loopMode) {
        case LoopMode.off:
          loopStatus = LoopStatus.none;
          shuffle = false;
          break;
        case LoopMode.all:
          loopStatus = LoopStatus.playlist;
          shuffle = false;
          break;
        case LoopMode.one:
          loopStatus = LoopStatus.track;
          shuffle = false;
          break;
        case LoopMode.random:
          loopStatus = LoopStatus.playlist;
          shuffle = true;
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
    await player.seek(player.position + Duration(microseconds: offset));
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
    }
    this.shuffle = shuffle;
  }
}
