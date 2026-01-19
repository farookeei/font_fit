import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// 0.0.1 ALGORITHM (The "Old" Way)
// ---------------------------------------------------------------------------
double runV1Algorithm(
  String data,
  double maxWidth,
  double minFontSize,
  double maxFontSize,
  int maxLines,
) {
  final style = const TextStyle(fontSize: 20); // Base style
  final precision = 0.25;
  final scale = 1.0;
  final textDir = TextDirection.ltr;

  // Internal fits function (recreated from v0.0.1)
  bool fits(double fs) {
    final span = TextSpan(text: data, style: style.copyWith(fontSize: fs));
    // V1 created a NEW TextPainter every time
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.start,
      textDirection: textDir,
      maxLines: maxLines,
      ellipsis: '\u2026',
    )..layout(maxWidth: maxWidth);

    final widthOK = tp.width <= maxWidth + 0.01;
    final linesOK = !(tp.didExceedMaxLines);
    return widthOK && linesOK;
  }

  double lo = minFontSize.clamp(0.0, maxFontSize);
  double hi = maxFontSize;
  double best = lo;
  int safety = 0;

  // Standard Binary Search
  while ((hi - lo) > precision && safety++ < 40) {
    final mid = (lo + hi) / 2;
    if (fits(mid * scale)) {
      best = mid;
      lo = mid;
    } else {
      hi = mid;
    }
  }

  return best;
}

// ---------------------------------------------------------------------------
// 0.0.2 ALGORITHM (The "New" Optimized Way)
// ---------------------------------------------------------------------------
double runV2Algorithm(
  String data,
  double maxWidth,
  double minFontSize,
  double maxFontSize,
  int maxLines,
) {
  // Optimization #4: Empty check (Simulated here, though loop handles it)
  if (data.isEmpty) return minFontSize;

  final style = const TextStyle(fontSize: 20);
  final precision = 0.25;
  final scale = 1.0;
  final textDir = TextDirection.ltr;

  // Optimization #1: Cached TextPainter
  final painter = TextPainter(
    textAlign: TextAlign.start,
    textDirection: textDir,
    maxLines: maxLines,
    ellipsis: '\u2026',
  );

  bool fits(double fs) {
    painter.text = TextSpan(text: data, style: style.copyWith(fontSize: fs));
    painter.layout(maxWidth: maxWidth);
    final widthOK = painter.width <= maxWidth + 0.01;
    final linesOK = !(painter.didExceedMaxLines);
    return widthOK && linesOK;
  }

  // Optimization #5: Single char check
  if (data.length <= 2) {
    if (fits(maxFontSize)) {
      painter.dispose();
      return maxFontSize;
    }
  }

  // Optimization #3: Adaptive precision
  final adaptivePrecision = (maxFontSize * 0.01).clamp(0.1, precision);

  double lo = minFontSize.clamp(0.0, maxFontSize);
  double hi = maxFontSize;
  double best = lo;

  // Optimization #2: Smart Initial Guess
  final estimatedCharWidth = maxFontSize * 0.6;
  final estimatedTotalWidth = data.length * estimatedCharWidth;

  if (estimatedTotalWidth > maxWidth) {
    final smartGuess =
        (maxWidth / data.length / 0.6).clamp(minFontSize, maxFontSize);
    if (fits(smartGuess)) {
      lo = smartGuess;
      best = smartGuess;
    } else {
      hi = smartGuess;
    }
  }

  int safety = 0;
  while ((hi - lo) > adaptivePrecision && safety++ < 40) {
    final mid = (lo + hi) / 2;
    if (fits(mid)) {
      best = mid;
      lo = mid;
    } else {
      hi = mid;
    }
  }

  painter.dispose();
  return best;
}

void main() {
  testWidgets('Performance Verification: V1 vs V2',
      (WidgetTester tester) async {
    // Setup Test Data
    const shortText = "Hi";
    const mediumText = "FontFit is a drop-in replacement for Text.";
    const longText =
        "This is a much longer text block that will definitely require significant resizing to fit within the constraints provided by the layout builder. It simulates a real world paragraph.";

    // Constraints
    const maxWidth = 200.0;
    const minFS = 10.0;
    const maxFS = 50.0;
    const maxLines = 2; // Force strict verify

    // ---------------------------------------------------
    // WARMUP (JIT Compilation)
    // ---------------------------------------------------
    print('🔥 Warming up JIT...');
    for (int i = 0; i < 100; i++) {
      runV1Algorithm(mediumText, maxWidth, minFS, maxFS, maxLines);
      runV2Algorithm(mediumText, maxWidth, minFS, maxFS, maxLines);
    }

    // ---------------------------------------------------
    // BENCHMARK EXECUTION
    // ---------------------------------------------------
    final int iterations = 2000;

    print('\n🚀 STARTING BENCHMARK ($iterations iterations each)\n');

    // --- CASE 1: SHORT TEXT ---
    final v1Short = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV1Algorithm(shortText, maxWidth, minFS, maxFS, maxLines);
    }
    v1Short.stop();

    final v2Short = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV2Algorithm(shortText, maxWidth, minFS, maxFS, maxLines);
    }
    v2Short.stop();

    // --- CASE 2: MEDIUM TEXT ---
    final v1Med = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV1Algorithm(mediumText, maxWidth, minFS, maxFS, maxLines);
    }
    v1Med.stop();

    final v2Med = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV2Algorithm(mediumText, maxWidth, minFS, maxFS, maxLines);
    }
    v2Med.stop();

    // --- CASE 3: LONG TEXT ---
    final v1Long = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV1Algorithm(longText, maxWidth, minFS, maxFS, maxLines);
    }
    v1Long.stop();

    final v2Long = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      runV2Algorithm(longText, maxWidth, minFS, maxFS, maxLines);
    }
    v2Long.stop();

    // ---------------------------------------------------
    // REPORTING
    // ---------------------------------------------------

    print('📊 RESULTS TABLE (Lower is Better)\n');
    print('| Test Case   | V1 Time (ms) | V2 Time (ms) | Improvement |');
    print('|-------------|--------------|--------------|-------------|');

    void report(String name, Stopwatch v1, Stopwatch v2) {
      final t1 = v1.elapsedMilliseconds;
      final t2 = v2.elapsedMilliseconds;
      final improvement = ((t1 - t2) / t1 * 100).toStringAsFixed(1);
      final emoji = t2 < t1 ? '✅' : '❌';

      print(
          '| $name | ${t1.toString().padLeft(12)} | ${t2.toString().padLeft(12)} | $emoji $improvement%  |');
    }

    report('Short Text ', v1Short, v2Short);
    report('Medium Text', v1Med, v2Med);
    report('Long Text  ', v1Long, v2Long);

    print('\n---------------------------------------------------');
    print('Note: "Short Text" uses the single-char optimization.');
    print('Note: "Long Text" uses the smart initial guess.');
    print('---------------------------------------------------\n');
  });
}
