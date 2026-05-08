import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pion/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Kita lewati config reader initialize karena ini test.
    await tester.pumpWidget(const PionApp());

    // Verify that bottom navigation exists
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
