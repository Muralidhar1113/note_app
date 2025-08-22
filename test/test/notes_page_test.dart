import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_note_app/main.dart';

void main() {
  testWidgets('notes page loads', (WidgetTester tester) async {
    // Pump the NotePage widget wrapped in MaterialApp
    await tester.pumpWidget(MaterialApp(home: NotePage()));

    // Check if AppBar title appears
    expect(find.text('Notes'), findsOneWidget);
  });
}
