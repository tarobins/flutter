import 'package:flutter/widgets.dart';

class ListItemScrollController {

  final ItemPositionNotifier itemPositionNotifier;
  final ScrollController scrollController;
  final SliverChildDelegate sliverChildDelegate;

  ListItemScrollController({@required this.itemPositionNotifier, @required this.scrollController, @required this.sliverChildDelegate});


}