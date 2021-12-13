import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoNavigationBar;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class _MoveWindow extends StatelessWidget {
  _MoveWindow({Key? key, this.child}) : super(key: key);
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          appWindow.startDragging();
        },
        onDoubleTap: () => appWindow.maximizeOrRestore(),
        child: this.child ?? Container());
  }
}

class PreferSizedMoveWindow extends StatelessWidget
    implements PreferredSizeWidget {
  final PreferredSizeWidget child;
  const PreferSizedMoveWindow({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _MoveWindow(
      child: child,
    );
  }

  @override
  Size get preferredSize => child.preferredSize;
}

class DraggableAppBar extends PlatformAppBar {
  final Key? widgetKey;

  final Widget? title;
  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? trailingActions;
  final bool? automaticallyImplyLeading;

  DraggableAppBar({
    Key? key,
    this.widgetKey,
    this.title,
    this.backgroundColor,
    this.leading,
    this.trailingActions,
    this.automaticallyImplyLeading,
  }) : super(
          key: key,
          widgetKey: widgetKey,
          title: title,
          backgroundColor: backgroundColor,
          leading: leading,
          trailingActions: trailingActions,
          automaticallyImplyLeading: automaticallyImplyLeading,
        );

  @override
  PreferredSizeWidget createMaterialWidget(BuildContext context) {
    return PreferSizedMoveWindow(child: super.createMaterialWidget(context));
  }

  @override
  CupertinoNavigationBar createCupertinoWidget(BuildContext context) {
    var child = super.createCupertinoWidget(context);
    return DraggableCupertinoNavigationBar(
      child: child,
    );
  }
}

class DraggableCupertinoNavigationBar extends CupertinoNavigationBar {
  final CupertinoNavigationBar child;
  const DraggableCupertinoNavigationBar({Key? key, required this.child})
      : super(key: key);

  @override
  Size get preferredSize => child.preferredSize;

  @override
  bool shouldFullyObstruct(BuildContext context) =>
      child.shouldFullyObstruct(context);

  @override
  State<DraggableCupertinoNavigationBar> createState() =>
      _DraggableCupertinoNavigationBarState();
}

class _DraggableCupertinoNavigationBarState
    extends State<DraggableCupertinoNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return _MoveWindow(
      child: widget.child,
    );
  }
}
