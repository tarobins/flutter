// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration animationDuration = Duration(seconds: 1);
const int itemCount = 200;

typedef ItemSize = double Function(int index);

void main() {
  ItemPositionNotifier itemPositionNotifier;
  ScrollController scrollController;
  SliverChildBuilderDelegate sliverChildBuilderDelegate;
  ListItemScrollController listItemScrollController;

  double _growBy20(int index) => (index + 1) * 20.0;
  double _always20(int index) => 20.0;

  Future<void> setUp(WidgetTester tester, {ItemSize itemSize}) async {
    tester.binding.window.physicalSizeTestValue = const Size(200.0, 200.0);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    itemPositionNotifier = ItemPositionNotifier();
    scrollController = ScrollController();
    sliverChildBuilderDelegate = SliverChildBuilderDelegate(
            (BuildContext context, int index) =>
            SizedBox(
              height: itemSize(index),
              child: Text('Item $index'),
            ),
        childCount: itemCount);
    listItemScrollController = ListItemScrollController(
        scrollController: scrollController, itemPositionNotifier: itemPositionNotifier, sliverChildDelegate: sliverChildBuilderDelegate);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.custom(
          childrenDelegate: sliverChildBuilderDelegate,
          controller: scrollController,
          itemPositionNotifier: itemPositionNotifier,
        ),
      ),
    );
  }

  testWidgets('List positions of unscrolled list', (WidgetTester tester) async {
    await setUp(tester, itemSize: _growBy20);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 0.1)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0.1, itemTrailingEdge: 0.3)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.3, itemTrailingEdge: 0.6)));
  });


  testWidgets('Linear scroll to already onscreen of height-20 items list', (WidgetTester tester) async {
    await setUp(tester, itemSize: _always20);

    listItemScrollController.animateTo(1, 0, animationDuration, Curves.linear);

    await tester.pump();
    await tester.pump(animationDuration * 0.5);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 0, itemLeadingEdge: -0.05, itemTrailingEdge: 0.05)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0.05, itemTrailingEdge: 0.15)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.15, itemTrailingEdge: 0.25)));

    await tester.pump(animationDuration * 0.5);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0, itemTrailingEdge: 0.1)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.1, itemTrailingEdge: 0.2)));
  });


  testWidgets('Linear scroll to not already onscreen of height-20 items list', (WidgetTester tester) async {
    await setUp(tester, itemSize: _always20);

    listItemScrollController.animateTo(20, 0, animationDuration, Curves.linear);

    await tester.pump();
    await tester.pump(animationDuration);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 20, itemLeadingEdge: 0, itemTrailingEdge: 0.1)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 21, itemLeadingEdge: 0.1, itemTrailingEdge: 0.2)));
  });
}
