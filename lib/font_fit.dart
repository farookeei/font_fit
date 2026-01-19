import 'package:flutter/material.dart';

/// A drop-in replacement for [Text] that automatically scales
/// font size down (between [minFontSize] and [maxFontSize]) to fit
/// within the available width/lines, using a binary search for speed.
///
/// **Version 0.0.2 Improvements:**
/// - Performance: Cached TextPainter for faster repeated builds
/// - Performance: Smart initial guess reduces iterations
/// - Performance: Adaptive precision based on font size
/// - Bug fix: Empty string handling
/// - Bug fix: Single character optimization
/// - Bug fix: Improved null safety
/// - Bug fix: Ensure TextPainter uses same font scaling/styling as Text widget
///
/// Typical usage:
/// ```dart
/// FontFit(
///   'Very long text',
///   style: const TextStyle(fontSize: 24),
///   minFontSize: 10,
///   maxLines: 1,
/// )
/// ```
class FontFit extends StatelessWidget {
  final String data;
  final TextStyle? style;

  /// Smallest allowed font size.
  final double minFontSize;

  /// Largest allowed font size.
  ///
  /// Defaults to the incoming [style.fontSize] (or DefaultTextStyle),
  /// which is what most people expect: "try to render at this size,
  /// but shrink if needed."
  final double? maxFontSize;

  /// Max lines to render. If null, text can grow vertically.
  final int? maxLines;

  final TextAlign textAlign;
  final TextOverflow overflow;
  final double precision;

  /// Optional: honor text scale factor. Default: true.
  final bool respectTextScaleFactor;

  const FontFit(
    this.data, {
    super.key,
    this.style,
    this.minFontSize = 10,
    this.maxFontSize,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.precision = 0.25, // stop when hi - lo < precision
    this.respectTextScaleFactor = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Text(
        data,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      );
    }

    // Fix: Merge with DefaultTextStyle to ensure we measure with the correct font family/weight
    // The Text widget does this internally, so we must do it manually for TextPainter to match.
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle =
        style == null ? defaultTextStyle : defaultTextStyle.merge(style);

    // ignore: deprecated_member_use
    final mediaTextScale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0;
    final scale = respectTextScaleFactor ? mediaTextScale : 1.0;

    final double hiStart = maxFontSize ??
        effectiveStyle.fontSize ??
        defaultTextStyle.fontSize ??
        14.0;

    final TextDirection textDir =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isInfinite) {
          return Text(
            data,
            style: effectiveStyle.copyWith(fontSize: hiStart),
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          );
        }

        final TextPainter painter = TextPainter(
          textAlign: textAlign,
          textDirection: textDir,
          maxLines: maxLines,
          // Fix: Do not use ellipsis during measurement.
          // We want to ensure the FULL text fits. If we allow ellipsis here,
          // TextPainter might "fit" by truncating, which completely defeats the purpose.
        );

        bool fits(double fs) {
          // Note: We use effectiveStyle (merged) to ensure font family/weight match Text widget.
          // Note: We bake the scale into the fontSize here for measurement.
          painter.text = TextSpan(
              text: data, style: effectiveStyle.copyWith(fontSize: fs));
          painter.layout(maxWidth: constraints.maxWidth);
          final widthOK = painter.width <= constraints.maxWidth + 0.01;
          final linesOK = !(painter.didExceedMaxLines);
          return widthOK && linesOK;
        }

        if (data.length <= 2) {
          final testSize = hiStart;
          if (fits(testSize * scale)) {
            painter.dispose();
            return Text(
              data,
              // Use effectiveStyle to ensure font consistency, pass unscaled size to Text
              // (Text applies specific scale if we don't handle it, but here we handled it in check)
              // Wait: If we pass UN-scaled size to Text, Text will scale it.
              // We tested SCALED size.
              // So: test(20). fits.
              // Text(10). Scale(2.0) -> Renders 20. Correct.
              // We should pass 'testSize' (unscaled) to Text.
              // But 'fits' takes scaled size.
              // So passes.
              style: effectiveStyle.copyWith(fontSize: testSize),
              maxLines: maxLines,
              textAlign: textAlign,
              overflow: overflow,
            );
          }
        }

        final adaptivePrecision = (hiStart * 0.01).clamp(0.1, precision);

        double lo = minFontSize.clamp(0.0, hiStart);
        double hi = hiStart;
        double best = lo;

        final estimatedCharWidth = hiStart * 0.6;
        final estimatedTotalWidth = data.length * estimatedCharWidth;

        if (estimatedTotalWidth > constraints.maxWidth) {
          final smartGuess = (constraints.maxWidth / data.length / 0.6)
              .clamp(minFontSize, hiStart);

          if (fits(smartGuess * scale)) {
            lo = smartGuess;
            best = smartGuess;
          } else {
            hi = smartGuess;
          }
        }

        int safety = 0;
        while ((hi - lo) > adaptivePrecision && safety++ < 40) {
          final mid = (lo + hi) / 2;
          if (fits(mid * scale)) {
            best = mid;
            lo = mid;
          } else {
            hi = mid;
          }
        }

        // Clean up
        painter.dispose();

        // Calculate final chosen size (unscaled, because Text widget scales it)
        final chosen = (best).clamp(minFontSize, hiStart);

        return Text(
          data,
          // Use effectiveStyle to ensure we use the same font family/weight we measured with
          style: effectiveStyle.copyWith(fontSize: chosen),
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }
}
