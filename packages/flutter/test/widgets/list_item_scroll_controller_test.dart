// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration animationDuration = Duration(seconds: 1);
const int itemCount = 200;
final double tolerance = pow(10, -5);

typedef ItemSize = double Function(int index);

void main() {
  ItemPositionNotifier itemPositionNotifier;
  ScrollController scrollController;
  SliverChildBuilderDelegate sliverChildBuilderDelegate;
  ListItemScrollController listItemScrollController;

  double _growBy20(int index) => (index + 1) * 20.0;
  double _growBy5(int index) => index * 5.0 + 10;
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

    listItemScrollController.animateTo(30, 0, animationDuration, Curves.linear);

    await tester.pump();
    await tester.pump(animationDuration);

    expect(itemPositionNotifier.itemPositions.value, closeToPosition(SliverChildPosition(index: 30, itemLeadingEdge: 0, itemTrailingEdge: 0.1), tolerance));
    expect(itemPositionNotifier.itemPositions.value, closeToPosition(SliverChildPosition(index: 31, itemLeadingEdge: 0.1, itemTrailingEdge: 0.2), tolerance));
  });

  testWidgets('Linear scroll to already onscreen of varying height items list', (WidgetTester tester) async {
    await setUp(tester, itemSize: _growBy20);

    listItemScrollController.animateTo(1, 0, animationDuration, Curves.linear);

    await tester.pump();
    await tester.pump(animationDuration * 0.5);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 0, itemLeadingEdge: -0.05, itemTrailingEdge: 0.05)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0.05, itemTrailingEdge: 0.25)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.25, itemTrailingEdge: 0.55)));

    await tester.pump(animationDuration * 0.5);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0, itemTrailingEdge: 0.2)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.2, itemTrailingEdge: 0.5)));
  });

  testWidgets('Linear scroll to not already onscreen of varying height items list', (WidgetTester tester) async {
    await setUp(tester, itemSize: _growBy5);

    listItemScrollController.animateTo(30, 0, animationDuration, Curves.linear);

    await tester.pump();
    await tester.pump(animationDuration);

    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 30, itemLeadingEdge: 0, itemTrailingEdge: 160/200)));
    expect(itemPositionNotifier.itemPositions.value, contains(SliverChildPosition(index: 31, itemLeadingEdge: 160/200, itemTrailingEdge: (160 + 165) / 200)));
  });
}

Matcher closeToPosition(SliverChildPosition expected, double tolerance) => ClosePositionMatcher(expected, tolerance);

class ClosePositionMatcher extends Matcher {
  final SliverChildPosition expectedChildPosition;
  final double tolerance;

  ClosePositionMatcher(this.expectedChildPosition, this.tolerance);

  @override
  Description describe(Description description) => description.add('position close to ').add(expectedChildPosition.toString());

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Iterable<SliverChildPosition>) {
      return false;
    }

    final Iterable<SliverChildPosition> sliverChildIterator = item;
    final Iterable<SliverChildPosition> matchingPositions = sliverChildIterator.where((SliverChildPosition sliverChildPosition) => sliverChildPosition.index == expectedChildPosition.index);

    if (matchingPositions.isEmpty) {
      return false;
    }

    final SliverChildPosition matchedPosition = matchingPositions.first;

    return isCloseTo(expectedChildPosition.itemLeadingEdge, matchedPosition.itemLeadingEdge) && isCloseTo(expectedChildPosition.itemTrailingEdge, matchedPosition.itemTrailingEdge);
  }

  bool isCloseTo(double a, double b) {
    return (a - b).abs() < tolerance;
  }
}
