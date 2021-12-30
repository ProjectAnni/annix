// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

extension PlatformIconsExt on BuildContext {
  /// Render either a Material or Cupertino icon based on the platform
  PlatformIcons get icons => PlatformIcons(this);

  IconData platformIcon({
    required IconData material,
    required IconData cupertino,
  }) =>
      isMaterial(this) ? material : cupertino;
}

class PlatformIcons {
  PlatformIcons(this.context);

  final BuildContext context;

  /// Icons: Icons.play_arrow_rounded : CupertinoIcons.play_arrow_solid
  IconData get playArrow => isMaterial(context)
      ? Icons.play_arrow_rounded
      : CupertinoIcons.play_arrow_solid;

  /// Icons: Icons.play_arrow_rounded : CupertinoIcons.play_arrow_solid
  IconData get play_circle => isMaterial(context)
      ? Icons.play_circle_rounded
      : CupertinoIcons.play_circle_fill;

  /// Icons: Icons.pause_rounded : CupertinoIcons.pause_solid
  IconData get pause =>
      isMaterial(context) ? Icons.pause_rounded : CupertinoIcons.pause_solid;

  /// Icons: Icons.shuffle_rounded : CupertinoIcons.shuffle
  IconData get shuffle =>
      isMaterial(context) ? Icons.shuffle_rounded : CupertinoIcons.shuffle;

  /// Icons: Icons.repeat_rounded : CupertinoIcons.repeat
  IconData get repeat =>
      isMaterial(context) ? Icons.repeat_rounded : CupertinoIcons.repeat;

  /// Icons: Icons.repeat_one_rounded : CupertinoIcons.repeat_1
  IconData get repeat_one =>
      isMaterial(context) ? Icons.repeat_one_rounded : CupertinoIcons.repeat_1;

  /// Icons: Icons.skip_previous_rounded : CupertinoIcons.backward_fill
  IconData get previous => isMaterial(context)
      ? Icons.skip_previous_rounded
      : CupertinoIcons.backward_fill;

  /// Icons: Icons.skip_next_rounded : CupertinoIcons.forward_fill
  IconData get next => isMaterial(context)
      ? Icons.skip_next_rounded
      : CupertinoIcons.forward_fill;

  /// Icons: Icons.expand_less_rounded : CupertinoIcons.chevron_up
  IconData get expand_up => isMaterial(context)
      ? Icons.expand_less_rounded
      : CupertinoIcons.chevron_up;

  /// Icons: Icons.expand_more_rounded : CupertinoIcons.chevron_down
  IconData get expand_down => isMaterial(context)
      ? Icons.expand_more_rounded
      : CupertinoIcons.chevron_down;

  /// Icons: Icons.error_rounded : CupertinoIcons.forward_fill
  IconData get error => isMaterial(context)
      ? Icons.error_rounded
      : CupertinoIcons.exclamationmark_circle_fill;

  /// Icons: Icons.person : CupertinoIcons.person_fill
  IconData get person =>
      isMaterial(context) ? Icons.person_rounded : CupertinoIcons.person_fill;

  /// Icons: Icons.settings_rounded : CupertinoIcons.settings
  IconData get settings =>
      isMaterial(context) ? Icons.settings_rounded : CupertinoIcons.settings;

  /// Icons: Icons.search_rounded : CupertinoIcons.search
  IconData get search =>
      isMaterial(context) ? Icons.search_rounded : CupertinoIcons.search;

  /// Icons: Icons.favorite_rounded : CupertinoIcons.heart_fill
  IconData get heart_filled =>
      isMaterial(context) ? Icons.favorite_rounded : CupertinoIcons.heart_fill;

  /// Icons: Icons.favorite_outline_rounded : CupertinoIcons.heart
  IconData get heart_outlined => isMaterial(context)
      ? Icons.favorite_outline_rounded
      : CupertinoIcons.heart;
}
