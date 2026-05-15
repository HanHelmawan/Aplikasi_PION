import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pion/main.dart'; // Adjust if package name is different, assuming pion

void main() {
  testWidgets('App start test', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR: ${details.exceptionAsString()}');
      print(details.stack);
    };

    try {
      await tester.pumpWidget(const PionApp());
      await tester.pumpAndSettle();
      print('NO ERROR ON STARTUP!');
    } catch (e, st) {
      print('CAUGHT EXCEPTION: $e');
      print(st);
    }
  });
}
