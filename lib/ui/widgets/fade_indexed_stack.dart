// https://gist.github.com/diegoveloper/1cd23e79a31d0c18a67424f0cbdfd7ad

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';

class FadeIndexedStack extends HookWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
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
      child: LazyLoadIndexedStack(
        index: index,
        alignment: alignment,
        textDirection: textDirection,
        sizing: sizing,
        children: children,
      ),
    );
  }
}
