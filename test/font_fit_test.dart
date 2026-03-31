
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

  testWidgets('FontFit.rich renders text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FontFit.rich(
            TextSpan(
              text: 'Rich ',
              children: [
                TextSpan(text: 'Text', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            style: TextStyle(fontSize: 24),
            minFontSize: 10,
            maxLines: 1,
          ),
        ),
      ),
    );

    // Find our widget
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Rich Text', findRichText: true), findsOneWidget);
  });

  testWidgets('FontFit.rich scales text down when constrained', (WidgetTester tester) async {
    // Give a tiny width so text must shrink
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 50,
          child: FontFit.rich(
            TextSpan(
              text: 'Very long ',
              children: [
                TextSpan(text: 'rich text', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            style: TextStyle(fontSize: 40),
            minFontSize: 8,
            maxLines: 1,
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));

    // For rich text, the scaling is done via textScaleFactor instead of copyWith(fontSize)
    // ignore: deprecated_member_use
    final textScaleFactor = textWidget.textScaleFactor ?? 1.0;
    
    // Scale factor should be less than 1.0 because it's constrained (base size is 40)
    expect(textScaleFactor, lessThan(1.0));
    // Min allowed scale is 8/40 = 0.2
    expect(textScaleFactor, greaterThanOrEqualTo(0.2));
  });

  testWidgets('FontFit respects vertical constraints', (WidgetTester tester) async {
    // Give a finite height but the width is infinite.
    // The text should shrink to fit the height.
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            height: 20,
            width: 1000, // plenty of width
            child: FontFit(
              'Tall text that should shrink to fit height',
              style: TextStyle(fontSize: 40),
              minFontSize: 8,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.byType(Text));

    // Should shrink because 40 is taller than 20
    expect(textWidget.style?.fontSize, lessThan(40));
    // It should fit within 20. At size 20 it might still be too tall due to line height,
    // so it should probably be around 14-16.
    expect(textWidget.style?.fontSize, lessThanOrEqualTo(20));
  });
}
