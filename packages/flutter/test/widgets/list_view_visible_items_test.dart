// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

void main() {
  testWidgets('List positions of unscrolled list', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(200.0, 200.0);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final ItemPositionNotifier itemScrollController = ItemPositionNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          children: List<Widget>.generate(
            15,
            (int i) => SizedBox(
              height: (i + 1) * 20.0,
              child: Text('Item $i'),
            ),
          ),
        itemScrollController: itemScrollController,
        ),
      ),
    );

    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 0, itemLeadingEdge: 0, itemTrailingEdge: 0.1)));
    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0.1, itemTrailingEdge: 0.3)));
    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.3, itemTrailingEdge: 0.6)));
  });

  testWidgets('List positions of scrolled list', (WidgetTester tester) async {
    tester.binding.window.physicalSizeTestValue = const Size(200.0, 200.0);
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    final ItemPositionNotifier itemScrollController = ItemPositionNotifier();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          children: List<Widget>.generate(
            15,
                (int i) => SizedBox(
              height: (i + 1) * 20.0,
              child: Text('Item $i'),
            ),
          ),
          itemScrollController: itemScrollController,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -20));
    await tester.pump();

    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 1, itemLeadingEdge: 0, itemTrailingEdge: 0.2)));
    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 2, itemLeadingEdge: 0.2, itemTrailingEdge: 0.5)));
    expect(itemScrollController.itemPositions.value, contains(SliverChildPosition(index: 3, itemLeadingEdge: 0.5, itemTrailingEdge: 0.9)));
  });
}
