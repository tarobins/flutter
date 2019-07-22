import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class ListItemScrollController {

  final ItemPositionNotifier itemPositionNotifier;
  final ScrollController scrollController;
  final SliverChildDelegate sliverChildDelegate;

  ListItemScrollController({@required this.itemPositionNotifier, @required this.scrollController, @required this.sliverChildDelegate});

  Future<void> animateTo(int index, double anchor, Duration duration, Curve curve) {
    final Iterable<SliverChildPosition> matchingPositions = itemPositionNotifier.itemPositions.value.where((SliverChildPosition sliverChildPosition) => sliverChildPosition.index == index);
    if (matchingPositions.isNotEmpty) {
      return _animateToOffScreenItem(index, anchor, duration, curve);
    } else {
      return _animateToOffScreenItem(index, anchor, duration, curve);
    }
  }

//  Future<void> _animateToOnScreenItem(SliverChildPosition targetItemPosition, double anchor, Duration duration, Curve curve) {
//    final double targetItemCurrentPixelEdge = targetItemPosition.itemLeadingEdge * scrollController.position.viewportDimension;
//    final double targetPixelOffset = anchor * scrollController.position.viewportDimension;
//
//    final double targetScrollOffset = targetItemCurrentPixelEdge - targetPixelOffset;
//
//    return scrollController.animateTo(targetScrollOffset, duration: duration, curve: curve);
//  }

  Future<void> _animateToOffScreenItem(int index, double anchor, Duration duration, Curve curve) {
//    final double averageItemHeight = itemPositionNotifier.itemPositions.value.fold(0.0, (double value, SliverChildPosition next) =>
//        value + next.itemTrailingEdge - next.itemLeadingEdge) /
//            itemPositionNotifier.itemPositions.value.length * scrollController.position.viewportDimension;
//
//    final double targetScrollOffset = index * averageItemHeight;

    final ScrollPositionWithSingleContext scrollPosition = scrollController.position;
    final ItemDrivenScrollActivity scrollActivity = ItemDrivenScrollActivity(
      scrollPosition,
      scrollPosition: scrollPosition,
      scrollController: scrollController,
      anchor: anchor,
      itemPositionNotifier: itemPositionNotifier,
      index: index,
      duration: duration,
      curve: curve,
      vsync: scrollPosition.context.vsync,
    );
    scrollPosition.beginActivity(scrollActivity);

    return scrollActivity.done;
  }
}
/// An activity that animates a scroll view based on animation parameters.
///
/// For example, a [DrivenScrollActivity] is used to implement
/// [ScrollController.animateTo].
///
/// See also:
///
///  * [BallisticScrollActivity], which animates a scroll view based on a
///    physics [Simulation].
class ItemDrivenScrollActivity extends ScrollActivity {

  final ItemPositionNotifier itemPositionNotifier;
  final ScrollController scrollController;
  final int index;
  final double anchor;
  final Curve curve;
  final double initialScrollPosition;

  /// Creates an activity that animates a scroll view based on animation
  /// parameters.
  ///
  /// All of the parameters must be non-null.
  ItemDrivenScrollActivity(
      ScrollActivityDelegate delegate, {
        ScrollController this.scrollController,
        ScrollPosition scrollPosition,
        ItemPositionNotifier this.itemPositionNotifier,
        @required int this.index,
        @required double this.anchor,
        @required Duration duration,
        @required Curve this.curve,
        @required TickerProvider vsync,
      }) : assert(scrollPosition != null),
        assert(index != null),
        assert(duration != null),
        assert(duration > Duration.zero),
        assert(curve != null),
        initialScrollPosition = scrollPosition.pixels,
        super(delegate) {
    _completer = Completer<void>();
    _controller = AnimationController(vsync: vsync, duration: duration);
//    _value = _controller.drive((Tween<double>(begin: scrollPosition.pixels, end: _estimatedTargetScrollOffsetDelta).chain(CurveTween(curve: curve))));
    _controller..addListener(_tick)..forward().whenComplete(_end);
  }

  Completer<void> _completer;
  AnimationController _controller;
//  Animation<double> _value;
//  Tween<double> _tween;
  Line _line;
  double curved;
  double offset;


  /// A [Future] that completes when the activity stops.
  ///
  /// For example, this [Future] will complete if the animation reaches the end
  /// or if the user interacts with the scroll view in way that causes the
  /// animation to stop before it reaches the end.
  Future<void> get done => _completer.future;

  @override
  double get velocity => _controller.velocity;

  void _tick() {

    if (_line == null) {
//      _tween = Tween<double>(begin: initialScrollPosition, end: _estimatedTargetScrollOffsetDelta);
      _line = Line(0, initialScrollPosition, 1, _estimatedTargetScrollOffset);
    } else {
      final double estimatedTargetScrollOffsetDelta = _estimatedTargetScrollOffset;
//      final double currentOffset = _line.eval(curved);
      _line = Line(curved, offset, 1, estimatedTargetScrollOffsetDelta);
    }
    curved = curve.transform(_controller.value);
    offset = _line.eval(curved);
    if (delegate.setPixels(offset) != 0.0)
      delegate.goIdle();
  }

  void _end() {
    delegate?.goBallistic(velocity);
  }

  double get _estimatedTargetScrollOffset {
    final Iterable<SliverChildPosition> matchingPositions = itemPositionNotifier.itemPositions.value.where((SliverChildPosition sliverChildPosition) => sliverChildPosition.index == index);

    if (matchingPositions.isNotEmpty) {
      SliverChildPosition targetItemPosition = matchingPositions.first;
      final double targetItemCurrentPixelEdge = targetItemPosition.itemLeadingEdge * scrollController.position.viewportDimension;
      final double targetPixelOffset = anchor * scrollController.position.viewportDimension;

      final double targetScrollOffset = targetItemCurrentPixelEdge - targetPixelOffset;

      return targetScrollOffset + (offset ?? 0);
    } else {
      final double averageItemHeight = itemPositionNotifier.itemPositions.value.fold(0.0, (double value, SliverChildPosition next) =>
          value + next.itemTrailingEdge - next.itemLeadingEdge) /
              itemPositionNotifier.itemPositions.value.length * scrollController.position.viewportDimension;

      final double targetScrollOffset = index * averageItemHeight;

      return targetScrollOffset;
    }
  }

  @override
  void dispatchOverscrollNotification(ScrollMetrics metrics, BuildContext context, double overscroll) {
    OverscrollNotification(metrics: metrics, context: context, overscroll: overscroll, velocity: velocity).dispatch(context);
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  @override
  void dispose() {
    _completer.complete();
    _controller.dispose();
    super.dispose();
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($_controller)';
  }
}

class Line {
  final double slope;
  final double yIntercept;

  Line(double x1, double y1, double x2, double y2) :
      slope = (y2 - y1) / (x2 - x1), yIntercept = y1 - (y2 - y1) / (x2 - x1) * x1;

  double eval(double x) => slope * x + yIntercept;

  @override
  String toString() => '$slope * x + $yIntercept';
}
