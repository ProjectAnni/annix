// import 'package:bitsdojo_window/bitsdojo_window.dart';
// import 'package:flutter/widgets.dart';

// class _MoveWindow extends StatelessWidget {
//   _MoveWindow({Key? key, this.child}) : super(key: key);
//   final Widget? child;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onPanStart: (details) {
//         appWindow.startDragging();
//       },
//       onDoubleTap: () => appWindow.maximizeOrRestore(),
//       child: this.child ?? Container(),
//     );
//   }
// }

// class PreferSizedMoveWindow extends StatelessWidget
//     implements PreferredSizeWidget {
//   final PreferredSizeWidget child;
//   const PreferSizedMoveWindow({Key? key, required this.child})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return _MoveWindow(
//       child: child,
//     );
//   }

//   @override
//   Size get preferredSize => child.preferredSize;
// }
