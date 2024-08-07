import 'dart:io';

import 'package:annix/providers.dart';
import 'package:annix/services/anniv/anniv.dart';
import 'package:annix/services/anniv/anniv_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/services/local/database.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_service_platform_interface/audio_service_platform_interface.dart';
import 'package:audio_session/audio_session.dart';
import 'package:drift/drift.dart';
import 'package:f_logs/f_logs.dart';
import 'package:anni_mpris_service/anni_mpris_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AnnixAudioHandler extends BaseAudioHandler {
  final Ref ref;

  final PlaybackService player;
  PlayingTrack? playing;

  final AnnivService anniv;
  final LocalDatabase database;

  List<LocalFavoriteTrack> _favorites = [];

  static Future<void> init(final Ref ref) async {
    if (Platform.isLinux) {
      AudioServicePlatform.instance = LinuxAudioService(ref);
    }

    final service = await AudioService.init(
      builder: () => AnnixAudioHandler._(ref),
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

    AudioSession.instance.then((final session) async {
      session.configure(const AudioSessionConfiguration.music());

      // unplugged
      session.becomingNoisyEventStream.listen((final _) => service.pause());

      bool pausedByInterrupt = false;
      // interruption
      session.interruptionEventStream.listen((final event) {
        if (event.begin) {
          FLog.info(text: 'handling interruption beginning ${event.type}');
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
          FLog.info(text: 'handling interruption end ${event.type}');
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

    AudioService.notificationClicked.listen((final clicked) {
      if (clicked) {
        final router = ref.read(routerProvider);
        router.slideController.show();
        router.panelController.open();
      }
    });
  }

  AnnixAudioHandler._(this.ref)
      : player = ref.read(playbackProvider),
        anniv = ref.read(annivProvider),
        database = ref.read(localDatabaseProvider) {
    player.addListener(() => _updatePlaybackState());
    database.localFavoriteTracks
        .select()
        .watch()
        .listen((final favorites) => _updatePlaybackState(favorites));
  }

  @override
  Future<void> play() async {
    return player.play(trackPlayback: false);
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
  Future<void> seek(final Duration position) {
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
      await anniv.toggleFavoriteTrack(track);
    }
  }

  void _updatePlaybackState([final List<LocalFavoriteTrack>? favorites]) {
    if (favorites != null) {
      _favorites = favorites;
    }

    if (playing != player.playing) {
      playing = player.playing;
      playing?.addListener(_updatePlaybackState);
    }

    final isPlaying = player.playerStatus == PlayerStatus.playing;
    final isFavorite = player.playing != null &&
        _favorites.any(
          (final f) =>
              player.playing!.track.id ==
              TrackIdentifier(
                albumId: f.albumId,
                discId: f.discId,
                trackId: f.trackId,
              ),
        );

    final controls = [
      if (!Platform.isIOS && !Platform.isMacOS)
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
      MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];

    final playState = PlaybackState(
      controls: controls,
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices:
          List.generate(controls.length, (final i) => i)
              .where((final i) =>
                  controls[i].action == MediaAction.fastForward ||
                  controls[i].action == MediaAction.pause ||
                  controls[i].action == MediaAction.play ||
                  controls[i].action == MediaAction.skipToNext)
              .toList(),
      processingState: {
        PlayerStatus.playing: AudioProcessingState.ready,
        PlayerStatus.stopped: AudioProcessingState.ready,
        PlayerStatus.paused: AudioProcessingState.ready,
        PlayerStatus.buffering: AudioProcessingState.buffering,
      }[player.playerStatus]!,
      playing: isPlaying,
      updatePosition: player.playing?.position ?? Duration.zero,
    );
    if (playbackState.value != playState) {
      try {
        playbackState.add(playState);
      } catch (e) {
        FLog.error(
          className: 'AnnixAudioHandler',
          methodName: '_updatePlaybackState',
          text: 'Failed to update playback state',
          exception: e,
        );
      }
    }

    if (playing != null &&
        (mediaItem.value?.id != playing?.id ||
            mediaItem.value?.duration !=
                (player.playing?.duration ?? Duration.zero))) {
      final proxy = ref.read(proxyProvider);
      mediaItem.add(MediaItem(
        id: playing!.id,
        title: playing!.track.title,
        album: playing!.track.albumTitle,
        artist: playing!.track.artist,
        duration: player.playing?.duration ?? Duration.zero,
        artUri: proxy.coverUri(
          playing!.identifier.albumId,
          playing!.identifier.discId,
        ),
      ));
    }
  }
}

class LinuxAudioService extends AudioServicePlatform {
  final AnnixMPRISService mpris;
  bool seekOnNextUpdate = false;

  LinuxAudioService(final Ref ref) : mpris = AnnixMPRISService(ref);

  @override
  Future<void> configure(final ConfigureRequest request) async {}

  @override
  Future<void> setState(final SetStateRequest request) async {
    mpris.playbackStatus =
        request.state.playing ? PlaybackStatus.playing : PlaybackStatus.stopped;
    mpris.updatePosition(request.state.updatePosition,
        forceEmitSeeked: seekOnNextUpdate);
    seekOnNextUpdate = false;
  }

  @override
  Future<void> setMediaItem(final SetMediaItemRequest request) async {
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
  Future<void> stopService(final StopServiceRequest request) async {}

  @override
  void setHandlerCallbacks(final AudioHandlerCallbacks callbacks) {}

  @override
  Future<void> setQueue(final SetQueueRequest request) async {}
}

class AnnixMPRISService extends MPRISService {
  final PlaybackService player;

  AnnixMPRISService(final Ref ref)
      : player = ref.read(playbackProvider),
        super(
          'annix',
          identity: 'Annix',
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
    await player.play(trackPlayback: false);
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
  Future<void> onSeek(final int offset) async {
    if (player.playing != null) {
      await player
          .seek(player.playing!.position + Duration(milliseconds: offset));
    }
  }

  @override
  Future<void> onSetPosition(final String trackId, final int position) async {
    await player.seek(Duration(microseconds: position));
  }

  @override
  Future<void> onLoopStatus(final LoopStatus loopStatus) async {
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
  Future<void> onShuffle(final bool shuffle) async {
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
