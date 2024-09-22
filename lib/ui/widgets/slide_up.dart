/*
Name: Zotov Vladimir
Date: 18/06/22
Purpose: Defines the package: sliding_up_panel2
Copyright: © 2022, Zotov Vladimir. All rights reserved.
Licensing: More information can be found here: https://github.com/Zotov-VD/sliding_up_panel/blob/master/LICENSE

This product includes software developed by Akshath Jain (https://akshathjain.com)
*/

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum PanelState { open, closed }

class SlidingUpPanel extends StatefulHookConsumerWidget {
  /// Returns the Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// of this Widget.
  final Widget panel;

  /// The Widget displayed overtop the [panel] when collapsed.
  /// This fades out as the panel is opened.
  final Widget collapsed;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

  /// A point between [minHeight] and [maxHeight] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([maxHeight] - [minHeight]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double? snapPoint;

  /// If non-null, the corners of the sliding panel sheet are rounded by this [BorderRadiusGeometry].
  final BorderRadiusGeometry? borderRadius;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position)? onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback? onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback? onPanelClosed;

  /// Allows toggling of the draggability of the SlidingUpPanel.
  /// Set this to false to prevent the user from being able to drag
  /// the panel up and down. Defaults to true.
  final bool isDraggable;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  const SlidingUpPanel(
      {Key? key,
      required this.collapsed,
      this.minHeight = 100.0,
      this.maxHeight = 500.0,
      this.snapPoint,
      this.borderRadius,
      this.panelSnapping = true,
      this.controller,
      this.onPanelSlide,
      this.onPanelOpened,
      this.onPanelClosed,
      this.isDraggable = true,
      this.defaultPanelState = PanelState.closed,
      required this.panel})
      : assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0),
        super(key: key);

  @override
  ConsumerState<SlidingUpPanel> createState() => _SlidingUpPanelState();
}

class _SlidingUpPanelState extends ConsumerState<SlidingUpPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  final ScrollController _sc = ScrollController();

  bool _scrollingEnabled = false;
  final _vt = VelocityTracker.withKind(PointerDeviceKind.touch);

  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: widget.defaultPanelState == PanelState.closed
            ? 0.0
            : 1.0 //set the default panel state (i.e. set initial value of _ac)
        )
      ..addListener(() {
        widget.onPanelSlide?.call(_ac.value);
        if (widget.onPanelOpened != null && _ac.value == 1.0) {
          widget.onPanelOpened!();
        }
        if (widget.onPanelClosed != null && _ac.value == 0.0) {
          widget.onPanelClosed!();
        }
      });

    // prevent the panel content from being scrolled only if the widget is
    // draggable and panel scrolling is enabled
    _sc.addListener(() {
      if (widget.isDraggable &&
          (!_scrollingEnabled || _panelPosition < 1) &&
          widget.controller?._forceScrollChange != true) {
        _sc.jumpTo(_scMinffset);
      }
    });

    widget.controller?._addState(this);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(),
        _isPanelVisible
            ? _gestureHandler(
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, child) {
                    return SizedBox(
                      height:
                          _ac.value * (widget.maxHeight - widget.minHeight) +
                              widget.minHeight,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      // open panel
                      OverflowBox(
                        minHeight: widget.maxHeight,
                        maxHeight: widget.maxHeight,
                        alignment: Alignment.topCenter,
                        child: _ac.value == 0
                            ? Container()
                            : FadeTransition(
                                opacity: TweenSequence<double>([
                                  TweenSequenceItem<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    weight: 10,
                                  ),
                                  TweenSequenceItem<double>(
                                    tween: Tween<double>(begin: 1.0, end: 1.0),
                                    weight: 90,
                                  ),
                                ]).animate(_ac),
                                child: widget.panel,
                              ),
                      ),

                      // collapsed panel
                      SizedBox(
                        height: widget.minHeight,
                        child: FadeTransition(
                          opacity: TweenSequence<double>([
                            TweenSequenceItem<double>(
                              tween: Tween<double>(begin: 1.0, end: 0.0),
                              weight: 20,
                            ),
                            TweenSequenceItem<double>(
                              tween: Tween<double>(begin: 0.0, end: 0.0),
                              weight: 80,
                            ),
                          ]).animate(_ac),

                          // if the panel is open ignore pointers (touch events) on the collapsed
                          // child so that way touch events go through to whatever is underneath
                          child: IgnorePointer(
                            ignoring: _isPanelOpen,
                            child: widget.collapsed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container()
      ],
    );
  }

  bool _ignoreScrollable = false;
  bool _isHorizontalScrollableWidget = false;
  Axis? _scrollableAxis;

  // returns a gesture detector if panel is used
  // and a listener if panel is used.
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({required Widget child}) {
    if (!widget.isDraggable) return child;

    return Listener(
      onPointerDown: (PointerDownEvent e) {
        final rb = context.findRenderObject() as RenderBox;
        final result = BoxHitTestResult();
        rb.hitTest(result, position: e.position);

        if (_panelPosition == 1) {
          _scMinffset = 0.0;
        }
        if (result.path.any((entry) =>
            entry.target.runtimeType == _HorizontalScrollableWidgetRenderBox)) {
          _isHorizontalScrollableWidget = true;
          widget.controller?._nowTargetForceDraggable = false;
        } else if (result.path.any((entry) =>
            entry.target.runtimeType ==
            _IgnoreDraggableWidgetWidgetRenderBox)) {
          _ignoreScrollable = true;
          return;
        }
        _ignoreScrollable = false;
        _vt.addPosition(e.timeStamp, e.position);
      },
      onPointerMove: (PointerMoveEvent e) {
        if (_scrollableAxis == null) {
          if (e.delta.dx.abs() > e.delta.dy.abs()) {
            _scrollableAxis = Axis.horizontal;
          } else if (e.delta.dx.abs() < e.delta.dy.abs()) {
            _scrollableAxis = Axis.vertical;
          }
        }

        if (_isHorizontalScrollableWidget &&
            _scrollableAxis == Axis.horizontal) {
          return;
        }

        if (_ignoreScrollable) return;
        // add current position for velocity tracking
        _vt.addPosition(e.timeStamp, e.position);
        _onGestureSlide(e.delta.dy);
      },
      onPointerUp: (PointerUpEvent e) {
        if (_ignoreScrollable) return;
        _scrollableAxis = null;
        _onGestureEnd(_vt.getVelocity());
      },
      child: child,
    );
  }

  double _scMinffset = 0.0;

  // handles the sliding gesture
  void _onGestureSlide(double dy) {
    if ((!_scrollingEnabled) ||
        _panelPosition < 1 ||
        widget.controller?._nowTargetForceDraggable == true) {
      _ac.value -= dy / (widget.maxHeight - widget.minHeight);
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    if (_isPanelOpen && _sc.hasClients && _sc.offset <= _scMinffset) {
      if (dy < 0) {
        _scrollingEnabled = true;
      } else {
        _scrollingEnabled = false;
      }
    }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    const minFlingVelocity = 365.0;
    const kSnap = 8;

    //let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (_isPanelOpen && _scrollingEnabled) return;

    //check if the velocity is sufficient to constitute fling to end
    final visualVelocity =
        -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    // get minimum distances to figure out where the panel is at
    final double d2Close = _ac.value;
    final double d2Open = 1 - _ac.value;
    final double d2Snap = ((widget.snapPoint ?? 3) - _ac.value)
        .abs(); // large value if null results in not every being the min
    final double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity ||
            minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);
        }

        // no snap point exists
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);

        // panel snapping disabled
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: const Duration(milliseconds: 410),
          curve: Curves.decelerate,
        );
      }

      return;
    }

    // check if the controller is already halfway there
    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1.0,
          stiffness: 500.0,
          ratio: 1.0,
        ),
        _ac.value,
        targetPos,
        velocity);

    _ac.animateWith(simulation);
  }

  //---------------------------------
  //PanelController related functions
  //---------------------------------

  //close the panel
  Future<void> _close() {
    return _ac.fling(velocity: -1.0);
  }

  //open the panel
  Future<void> _open() {
    return _ac.fling(velocity: 1.0);
  }

  //hide the panel (completely offscreen)
  Future<void> _hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  //show the panel (in collapsed mode)
  Future<void> _show() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = true;
      });
    });
  }

  //animate the panel position to value - must
  //be between 0.0 and 1.0
  Future<void> _animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  //animate the panel position to the snap point
  //REQUIRES that widget.snapPoint != null
  Future<void> _animatePanelToSnapPoint(
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint!, duration: duration, curve: curve);
  }

  //set the panel position to value - must
  //be between 0.0 and 1.0
  set _panelPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  //get the current panel position
  //returns the % offset from collapsed state
  //as a decimal between 0.0 and 1.0
  double get _panelPosition => _ac.value;

  //returns whether or not
  //the panel is still animating
  bool get _isPanelAnimating => _ac.isAnimating;

  //returns whether or not the
  //panel is open
  bool get _isPanelOpen => _ac.value == 1.0;

  //returns whether or not the
  //panel is closed
  bool get _isPanelClosed => _ac.value == 0.0;

  //returns whether or not the
  //panel is shown/hidden
  bool get _isPanelShown => _isPanelVisible;
}

class PanelController {
  _SlidingUpPanelState? _panelState;

  void _addState(_SlidingUpPanelState panelState) {
    _panelState = panelState;
  }

  bool _forceScrollChange = false;

  /// use this function when scroll change in func
  /// Example:
  /// panelController.forseScrollChange(scrollController.animateTo(100, duration: Duration(milliseconds: 400), curve: Curves.ease))
  Future<void> forseScrollChange(Future func) async {
    _forceScrollChange = true;
    _panelState!._scrollingEnabled = true;
    await func;
    // if (_panelState!._sc.offset == 0) {
    //   _panelState!._scrollingEnabled = true;
    // }
    if (panelPosition < 1) {
      _panelState!._scMinffset = _panelState!._sc.offset;
    }
    _forceScrollChange = false;
  }

  bool _nowTargetForceDraggable = false;

  /// Determine if the panelController is attached to an instance
  /// of the SlidingUpPanel (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _panelState != null;

  /// Closes the sliding panel to its collapsed state (i.e. to the  minHeight)
  Future<void> close() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._close();
  }

  /// Opens the sliding panel fully
  /// (i.e. to the maxHeight)
  Future<void> open() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._open();
  }

  /// Hides the sliding panel (i.e. is invisible)
  Future<void> hide() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._hide();
  }

  /// Shows the sliding panel in its collapsed state
  /// (i.e. "un-hide" the sliding panel)
  Future<void> show() {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._show();
  }

  /// Animates the panel position to the value.
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToPosition(double value,
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(0.0 <= value && value <= 1.0);
    return _panelState!
        ._animatePanelToPosition(value, duration: duration, curve: curve);
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint(
      {Duration? duration, Curve curve = Curves.linear}) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(_panelState!.widget.snapPoint != null,
        'SlidingUpPanel snapPoint property must not be null');
    return _panelState!
        ._animatePanelToSnapPoint(duration: duration, curve: curve);
  }

  /// Sets the panel position (without animation).
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  set panelPosition(double value) {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    assert(0.0 <= value && value <= 1.0);
    _panelState!._panelPosition = value;
  }

  /// Gets the current panel position.
  /// Returns the % offset from collapsed state
  /// to the open state
  /// as a decimal between 0.0 and 1.0
  /// where 0.0 is fully collapsed and
  /// 1.0 is full open.
  double get panelPosition {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._panelPosition;
  }

  /// Returns whether or not the panel is
  /// currently animating.
  bool get isPanelAnimating {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelAnimating;
  }

  /// Returns whether or not the
  /// panel is open.
  bool get isPanelOpen {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelOpen;
  }

  /// Returns whether or not the
  /// panel is closed.
  bool get isPanelClosed {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelClosed;
  }

  /// Returns whether or not the
  /// panel is shown/hidden.
  bool get isPanelShown {
    assert(isAttached, 'PanelController must be attached to a SlidingUpPanel');
    return _panelState!._isPanelShown;
  }
}

/// if you want to prevent the panel from being dragged using the widget,
/// wrap the widget with this
class IgnoreDraggableWidget extends SingleChildRenderObjectWidget {
  const IgnoreDraggableWidget({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _IgnoreDraggableWidgetWidgetRenderBox();
  }
}

class _IgnoreDraggableWidgetWidgetRenderBox extends RenderPointerListener {
  @override
  HitTestBehavior get behavior => HitTestBehavior.opaque;
}

/// if you want to prevent unwanted panel dragging when scrolling widgets [Scrollable] with horizontal axis
/// wrap the widget with this
class HorizontalScrollableWidget extends SingleChildRenderObjectWidget {
  const HorizontalScrollableWidget({super.key, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HorizontalScrollableWidgetRenderBox();
  }
}

class _HorizontalScrollableWidgetRenderBox extends RenderPointerListener {
  @override
  HitTestBehavior get behavior => HitTestBehavior.opaque;
}
