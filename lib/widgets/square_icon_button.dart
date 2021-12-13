import 'package:flutter/material.dart' show RawMaterialButton;
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
      child: PlatformWidget(
        material: (context, platform) => RawMaterialButton(
          shape: BeveledRectangleBorder(),
          child: child,
          onPressed: onPressed,
        ),
        cupertino: (context, platform) => PlatformIconButton(
          icon: child,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
