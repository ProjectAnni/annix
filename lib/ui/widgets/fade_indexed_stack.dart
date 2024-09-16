// https://gist.github.com/diegoveloper/1cd23e79a31d0c18a67424f0cbdfd7ad

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FadeIndexedStack extends HookWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final Clip clipBehavior;
  final StackFit sizing;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(
      milliseconds: 300,
    ),
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.clipBehavior = Clip.hardEdge,
    this.sizing = StackFit.loose,
  });

  @override
  Widget build(BuildContext context) {
    final animation =
        useAnimationController(duration: duration, initialValue: 1.0);

    useEffect(() {
      animation.forward(from: 0.0);
      return null;
    }, [index]);

    return FadeTransition(
      opacity: animation,
      child: IndexedStack(
        index: index,
        alignment: alignment,
        textDirection: textDirection,
        clipBehavior: clipBehavior,
        sizing: sizing,
        children: children,
      ),
    );
  }
}
