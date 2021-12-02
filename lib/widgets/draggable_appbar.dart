import 'package:annix/services/window.dart';
import 'package:flutter/material.dart';

class DraggableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const DraggableAppBar({Key? key, required this.appBar}) : super(key: key);

  @override
  _DraggableAppBarState createState() => _DraggableAppBarState();

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}

class _DraggableAppBarState extends State<DraggableAppBar> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.appBar,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
    );
  }

  Offset? startPosition;
  void onPanStart(DragStartDetails details) async {
    startPosition = details.globalPosition;
  }

  void onPanUpdate(DragUpdateDetails details) async {
    var now = details.globalPosition;
    await AnnilWindow.updatePositionDelta(
      Offset(now.dx - startPosition!.dx, now.dy - startPosition!.dy),
    );
  }
}
