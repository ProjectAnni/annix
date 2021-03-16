import 'package:flutter/material.dart';

class SquareIconButton extends StatelessWidget {
  final Widget? child;

  final VoidCallback? onPressed;

  SquareIconButton({
    Key? key,
    @required this.child,
    @required this.onPressed,
  }) : super(key: key);

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
