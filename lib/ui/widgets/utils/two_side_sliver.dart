// Modified from https://stackoverflow.com/questions/65034208/how-to-make-customscrollview-has-2-or-multiple-row/72705975#72705975

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TwoSideSliver extends MultiChildRenderObjectWidget {
  final double leftPercentage;
  final Widget left;
  final Widget right;

  TwoSideSliver({
    super.key,
    this.leftPercentage = 0.5,
    required this.left,
    required this.right,
  })  : assert(leftPercentage >= 0 && leftPercentage <= 1),
        super(children: [left, right]);

  @override
  _RenderTwoSideSliver createRenderObject(BuildContext context) {
    return _RenderTwoSideSliver(leftPercentage: leftPercentage);
  }

  @override
  void updateRenderObject(BuildContext _, _RenderTwoSideSliver renderObject) {
    renderObject.leftPercentage = leftPercentage;
  }
}

extension _TwoSideParentDataExt on RenderSliver {
  /// Shortcut for [parentData]
  _TwoSideParentData get twoSide => parentData! as _TwoSideParentData;
}

class _TwoSideParentData extends SliverPhysicalParentData
    with ContainerParentDataMixin<RenderSliver> {}

class _RenderTwoSideSliver extends RenderSliver
    with ContainerRenderObjectMixin<RenderSliver, _TwoSideParentData> {
  _RenderTwoSideSliver({required double leftPercentage})
      : _leftPercentage = leftPercentage;

  double get leftPercentage => _leftPercentage;
  double _leftPercentage;

  set leftPercentage(double value) {
    if (_leftPercentage == value) return;
    _leftPercentage = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderSliver child) {
    if (child.parentData is! _TwoSideParentData) {
      child.parentData = _TwoSideParentData();
    }
  }

  RenderSliver get left => _children.elementAt(0);

  RenderSliver get right => _children.elementAt(1);

  Iterable<RenderSliver> get _children sync* {
    RenderSliver? child = firstChild;
    while (child != null) {
      yield child;
      child = childAfter(child);
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    left.layout(
      parentUsesSize: true,
      constraints.copyWith(
          crossAxisExtent: constraints.crossAxisExtent * leftPercentage),
    );

    right.layout(
      parentUsesSize: true,
      constraints.copyWith(
        crossAxisExtent: constraints.crossAxisExtent -
            constraints.crossAxisExtent * leftPercentage,
      ),
    );

    right.twoSide.paintOffset =
        Offset(constraints.crossAxisExtent * leftPercentage, 0);

    if (left.geometry!.scrollExtent > right.geometry!.scrollExtent) {
      geometry = left.geometry;
    } else {
      geometry = right.geometry;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!geometry!.visible) return;
    context.paintChild(left, offset);
    context.paintChild(
        right,
        Offset(offset.dx + constraints.crossAxisExtent * leftPercentage,
            offset.dy));
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    for (final child in _childrenInHitTestOrder) {
      if (child.geometry!.visible) {
        final hit = child.hitTest(
          result,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition - child.twoSide.paintOffset.dx,
        );

        if (hit) return true;
      }
    }
    return false;
  }

  Iterable<RenderSliver> get _childrenInHitTestOrder sync* {
    RenderSliver? child = lastChild;
    while (child != null) {
      yield child;
      child = childBefore(child);
    }
  }

  /// Important!
  /// Otherwise Widgets like [Slider] or [PopupMenuButton] won't work even
  /// though the rest of Widget will work (like [ElevatedButton])
  @override
  void applyPaintTransform(RenderSliver child, Matrix4 transform) {
    child.twoSide.applyPaintTransform(transform);
  }
}
