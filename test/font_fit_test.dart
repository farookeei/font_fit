
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_fit/font_fit.dart';

void main() {
  testWidgets('FontFit renders text without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FontFit(
            'Hello World',
            style: TextStyle(fontSize: 24),
            minFontSize: 10,
            maxLines: 1,
          ),
        ),
      ),
    );

    // Find our widget
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('FontFit scales text down when constrained', (WidgetTester tester) async {
    // Give a tiny width so text must shrink
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 50,
          child: FontFit(
            'Very long text that should shrink',
            style: TextStyle(fontSize: 40),
            minFontSize: 8,
            maxLines: 1,
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));

    // Should not be the original large 40
    expect(textWidget.style?.fontSize, lessThan(40));
    expect(textWidget.style?.fontSize, greaterThanOrEqualTo(8));
  });

  testWidgets('FontFit respects minFontSize', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 20,
          child: FontFit(
            'Text',
            style: TextStyle(fontSize: 40),
            minFontSize: 12,
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.style?.fontSize, greaterThanOrEqualTo(12));
  });
}
