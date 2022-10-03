import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/global.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:provider/provider.dart';
import 'package:annix/i18n/strings.g.dart';

extension on LyricAlign {
  TextAlign get textAlign {
    switch (this) {
      case LyricAlign.LEFT:
        return TextAlign.left;
      case LyricAlign.RIGHT:
        return TextAlign.right;
      case LyricAlign.CENTER:
        return TextAlign.center;
    }
  }

  Alignment get alignment {
    switch (this) {
      case LyricAlign.LEFT:
        return Alignment.topLeft;
      case LyricAlign.CENTER:
        return Alignment.center;
      case LyricAlign.RIGHT:
        return Alignment.centerRight;
    }
  }
}

class PlayingLyricUI extends LyricUI {
  final LyricAlign align;
  final bool isKaraoke;
  final TextTheme textTheme;

  PlayingLyricUI({
    required this.textTheme,
    this.align = LyricAlign.CENTER,
    required this.isKaraoke,
  });

  @override
  TextStyle getPlayingMainTextStyle() {
    return textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w500,
      height: 1,
      color: isKaraoke ? null : Global.context.colorScheme.primary,
    );
  }

  @override
  TextStyle getOtherMainTextStyle() {
    final theme = textTheme.bodyMedium;
    return theme!.copyWith(color: theme.color!.withOpacity(0.5));
  }

  @override
  double getInlineSpace() => 10;

  @override
  double getLineSpace() => 18;

  @override
  LyricAlign getLyricHorizontalAlign() {
    return align;
  }

  @override
  TextStyle getPlayingExtTextStyle() {
    return getPlayingMainTextStyle().apply(fontSizeFactor: 0.8);
  }

  @override
  TextStyle getOtherExtTextStyle() {
    return getOtherMainTextStyle().apply(fontSizeFactor: 0.8);
  }

  @override
  double getPlayingLineBias() {
    return Global.isDesktop
        ? 0.2 // on desktop, we tend to make lyric display at top
        : 0.5; // but on mobile phone, it would look better at the center of the screen
  }

  @override
  Color getLyricHightlightColor() {
    return Global.context.colorScheme.primary;
  }

  @override
  bool enableLineAnimation() => true;

  @override
  bool enableHighlight() => isKaraoke;
}

class LyricView extends StatelessWidget {
  final LyricAlign alignment;

  const LyricView({super.key, this.alignment = LyricAlign.CENTER});

  @override
  Widget build(BuildContext context) {
    return Selector<PlaybackService, PlayingTrack?>(
      selector: (_, player) => player.playing,
      builder: (context, playing, child) {
        return ChangeNotifierProvider.value(
          value: playing,
          builder: (context, child) {
            return Selector<PlayingTrack?, TrackLyric?>(
              selector: (_, playing) => playing?.lyric,
              builder: (context, lyric, child) {
                return _LyricView(
                  lyric: lyric,
                  lyricAlign: alignment,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _LyricView extends StatelessWidget {
  final LyricAlign lyricAlign;
  final TrackLyric? lyric;

  const _LyricView({
    Key? key,
    this.lyric,
    this.lyricAlign = LyricAlign.CENTER,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lyric == null) {
      return Align(
        alignment: lyricAlign.alignment,
        child: const Text('Loading...'),
      );
    } else if (lyric!.isEmpty) {
      if (lyric!.type == TrackType.normal) {
        return Align(
          alignment: lyricAlign.alignment,
          child: Text(t.no_lyric_found),
        );
      } else {
        return Align(
          alignment: lyricAlign.alignment,
          child: Text(lyric!.type.toString()),
        );
      }
    } else {
      if (lyric!.lyric.model == null) {
        // plain text
        return _textLyric(context, lyric!.lyric.text);
      } else {
        // lrc / karaoke
        // Notice: ui MUST NOT be rebuilt. building ui is EXTREMELY expensive
        final isKaraoke = lyric?.lyric.model?.lyrics[0].spanList != null;

        final ui = PlayingLyricUI(
          textTheme: context.textTheme,
          align: lyricAlign,
          isKaraoke: isKaraoke,
        );
        return Consumer<PlaybackService>(
          builder: (iconColor, player, child) {
            return ChangeNotifierProvider.value(
              value: player.playing,
              child: Selector<PlayingTrack?, int?>(
                selector: (_, playing) => playing?.position.inMilliseconds,
                builder: (context, position, child) {
                  return LyricsReader(
                    model: lyric!.lyric.model,
                    lyricUi: ui,
                    position: position ?? 0,
                    playing: player.playerStatus == PlayerStatus.playing,
                    emptyBuilder: () => _textLyric(context, lyric!.lyric.text),
                  );
                },
              ),
            );
          },
        );
      }
    }
  }

  Widget _textLyric(BuildContext context, String text) {
    return SingleChildScrollView(
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Text(
          text,
          textAlign: lyricAlign.textAlign,
          style: context.textTheme.bodyLarge!.copyWith(height: 2),
        ),
      ),
    );
  }
}
