import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ListItemScrollController {

  final ItemPositionNotifier itemPositionNotifier;
  final ScrollController scrollController;
  final SliverChildDelegate sliverChildDelegate;

  ListItemScrollController({@required this.itemPositionNotifier, @required this.scrollController, @required this.sliverChildDelegate});

  Future<void> animateTo(int index, double anchor, Duration duration, Curve curve) {
    final SliverChildPosition targetItemPosition = itemPositionNotifier.itemPositions.value.firstWhere((SliverChildPosition sliverChildPosition) => sliverChildPosition.index == index);
    final double targetItemCurrentPixelEdge = targetItemPosition.itemLeadingEdge * scrollController.position.viewportDimension;
    final double targetPixelOffset = anchor * scrollController.position.viewportDimension;

    final double targetScrollOffset = targetItemCurrentPixelEdge - targetPixelOffset;

    return scrollController.animateTo(targetScrollOffset, duration: duration, curve: curve);
  }
}