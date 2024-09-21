import 'package:annix/providers.dart';
import 'package:annix/services/metadata/metadata_model.dart';
import 'package:annix/services/playback/playback.dart';
import 'package:annix/ui/widgets/slide_up.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:annix/i18n/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  final BuildContext context;

  final LyricAlign align;
  final bool isKaraoke;
  final TextTheme textTheme;

  PlayingLyricUI(
    this.context, {
    required this.textTheme,
    this.align = LyricAlign.CENTER,
    required this.isKaraoke,
  });

  @override
  TextStyle getPlayingMainTextStyle() {
    return textTheme.headlineMedium!
        .copyWith(
          fontWeight: FontWeight.w600,
          color: isKaraoke
              ? context.colorScheme.onSecondaryContainer
              : getLyricHightlightColor(),
        )
        .apply(fontSizeFactor: 0.9);
  }

  @override
  TextStyle getOtherMainTextStyle() {
    return textTheme.titleMedium!.copyWith(
      height: 1,
      color: context.colorScheme.onSecondaryContainer
          .withValues(alpha: isKaraoke ? 0.8 : 0.5),
    );
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
  double getInlineSpace() => 8;

  @override
  double getLineSpace() => 24;

  @override
  LyricAlign getLyricHorizontalAlign() {
    return align;
  }

  @override
  double getPlayingLineBias() {
    return context.isDesktopOrLandscape
        ? 0.2 // on desktop, we tend to make lyric display at top
        : 0.5; // but on mobile phone, it would look better at the center of the screen
  }

  @override
  Color getLyricHightlightColor() {
    return context.colorScheme.primary;
  }

  @override
  bool enableLineAnimation() => true;

  @override
  bool enableHighlight() => isKaraoke;
}

class LyricView extends ConsumerWidget {
  final LyricAlign alignment;

  const LyricView({super.key, this.alignment = LyricAlign.LEFT});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final lyric = ref.watch(playingProvider.select((final p) => p.lyric));
    return _LyricView(
      lyric: lyric,
      lyricAlign: alignment,
    );
  }
}

class _LyricView extends StatelessWidget {
  final LyricAlign lyricAlign;
  final TrackLyric? lyric;

  const _LyricView({
    this.lyric,
    this.lyricAlign = LyricAlign.LEFT,
  });

  @override
  Widget build(final BuildContext context) {
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
          context,
          textTheme: context.textTheme,
          align: lyricAlign,
          isKaraoke: isKaraoke,
        );
        return Consumer(
          builder: (final iconColor, final ref, final child) {
            final player = ref.watch(playbackProvider);
            final position =
                ref.watch(playingProvider.select((final p) => p.position));
            return IgnoreDraggableWidget(
              child: LyricsReader(
                model: lyric!.lyric.model,
                lyricUi: ui,
                position: position.inMilliseconds,
                playing: player.playerStatus == PlayerStatus.playing,
                emptyBuilder: () => _textLyric(context, lyric!.lyric.text),
              ),
            );
          },
        );
      }
    }
  }

  Widget _textLyric(final BuildContext context, final String text) {
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
