import 'package:bitsdojo_window/bitsdojo_window.dart';
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
    return MoveWindow(
      child: widget.appBar,
    );
  }
}
