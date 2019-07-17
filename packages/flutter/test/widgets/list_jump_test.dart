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
          itemPositionNotifier: itemScrollController,
        ),
      ),
    );

    debugDumpRenderTree();

    expect(find.text('Item 0'), findsOneWidget);
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.text('Item 4'), findsNothing);
  });

}