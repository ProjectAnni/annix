import 'package:flutter/material.dart';

class SquareIconButton extends StatelessWidget {
  final Widget? child;

  final VoidCallback? onPressed;

  SquareIconButton({@required this.child, @required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: RawMaterialButton(
        shape: BeveledRectangleBorder(),
        child: child,
        onPressed: onPressed,
      ),
    );
  }
}
