import 'package:annix/services/player.dart';
import 'package:annix/services/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
        return Alignment.centerLeft;
      case LyricAlign.CENTER:
        return Alignment.center;
      case LyricAlign.RIGHT:
        return Alignment.centerRight;
    }
  }
}

class PlayingLyricUI extends LyricUI {
  final LyricAlign align;

  PlayingLyricUI({this.align = LyricAlign.CENTER});

  @override
  TextStyle getPlayingMainTextStyle() {
    return Theme.of(Global.context).textTheme.titleMedium!;
  }

  @override
  TextStyle getOtherMainTextStyle() {
    final textTheme = Theme.of(Global.context).textTheme.bodyMedium;
    return textTheme!.copyWith(color: textTheme.color!.withOpacity(0.5));
  }

  @override
  double getInlineSpace() => 20;

  @override
  double getLineSpace() => 20;

  @override
  LyricAlign getLyricHorizontalAlign() {
    return align;
  }

  @override
  TextStyle getPlayingExtTextStyle() {
    // TODO: custom style
    return TextStyle(color: Colors.grey[300], fontSize: 14);
  }

  @override
  TextStyle getOtherExtTextStyle() {
    // TODO: custom style
    return TextStyle(color: Colors.grey[300], fontSize: 14);
  }

  @override
  double getPlayingLineBias() {
    return Global.isDesktop
        ? 0.2 // on desk, we tend to make lyric display at top
        : 0.5; // but on mobile phone, it would look better at the center of the screen
  }

  @override
  Color getLyricHightlightColor() {
    return Theme.of(Global.context).colorScheme.primary;
  }

  @override
  bool enableLineAnimation() => true;
}

class LyricView extends StatelessWidget {
  final LyricAlign alignment;

  const LyricView({super.key, this.alignment = LyricAlign.CENTER});

  @override
  Widget build(BuildContext context) {
    return Selector<PlayerService, String?>(
      selector: (_, player) => player.playingLyric,
      builder: (context, lyric, child) {
        return _LyricView(
          lyric: lyric,
          lyricAlign: alignment,
        );
      },
    );
  }
}

class _LyricView extends StatelessWidget {
  final LyricAlign lyricAlign;
  final String? lyric;

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
        child: const Text("Loading..."),
      );
    } else if (lyric!.isEmpty) {
      return Align(
        alignment: lyricAlign.alignment,
        child: const Text("No lyrics found"),
      );
    } else {
      // Notice: model and ui MUST NOT be rebuilt
      // building ui is EXTREMELY expensive
      final model = LyricsModelBuilder.create()
          .bindLyricToMain(lyric!)
          // .bindLyricToExt(lyric) // TODO: translation
          .getModel();
      final ui = PlayingLyricUI(align: lyricAlign);
      return Selector<PlayingProgress, Duration>(
        selector: (_, progress) => progress.position,
        builder: (context, position, child) {
          return LyricsReader(
            model: model,
            lyricUi: ui,
            position: position.inMilliseconds /* + 500 as offset */,
            // don't know why only playing = false has highlight
            playing: true,
            emptyBuilder: () {
              return SingleChildScrollView(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Text(
                    lyric!,
                    textAlign: lyricAlign.textAlign,
                    style: context.textTheme.bodyText1!.copyWith(height: 2),
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}
