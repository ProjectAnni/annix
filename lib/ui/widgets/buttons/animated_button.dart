import 'package:flutter/material.dart';

class AnimatedIconWidget extends AnimatedWidget {
  final AnimatedIconData icon;

  const AnimatedIconWidget({
    super.key,
    required this.icon,
    required final AnimationController controller,
  }) : super(listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(final BuildContext context) {
    return AnimatedIcon(
      icon: icon,
      progress: _progress,
    );
  }
}
