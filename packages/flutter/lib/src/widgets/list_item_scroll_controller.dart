import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ListItemScrollController {

  final ItemPositionNotifier itemPositionNotifier;
  final ScrollController scrollController;
  final SliverChildDelegate sliverChildDelegate;

  ListItemScrollController({@required this.itemPositionNotifier, @required this.scrollController, @required this.sliverChildDelegate});

  Future<void> animateTo(int index, double anchor, Duration duration, Curve curve) {
    final Iterable<SliverChildPosition> matchingPositions = itemPositionNotifier.itemPositions.value.where((SliverChildPosition sliverChildPosition) => sliverChildPosition.index == index);
    if (matchingPositions.isNotEmpty) {
      return _animateToOnScreenItem(matchingPositions.first, anchor, duration, curve);
    } else {
      return _animateToOffScreenItem(index, anchor, duration, curve);
    }
  }

  Future<void> _animateToOnScreenItem(SliverChildPosition targetItemPosition, double anchor, Duration duration, Curve curve) {
    final double targetItemCurrentPixelEdge = targetItemPosition.itemLeadingEdge * scrollController.position.viewportDimension;
    final double targetPixelOffset = anchor * scrollController.position.viewportDimension;

    final double targetScrollOffset = targetItemCurrentPixelEdge - targetPixelOffset;

    return scrollController.animateTo(targetScrollOffset, duration: duration, curve: curve);
  }

  Future<void> _animateToOffScreenItem(int index, double anchor, Duration duration, Curve curve) {
    final double averageItemHeight = itemPositionNotifier.itemPositions.value.fold(0.0, (double value, SliverChildPosition next) =>
        value + next.itemTrailingEdge - next.itemLeadingEdge) /
            itemPositionNotifier.itemPositions.value.length * scrollController.position.viewportDimension;

    final double targetScrollOffset = index * averageItemHeight;

    return scrollController.animateTo(targetScrollOffset, duration: duration, curve: curve);
  }
}