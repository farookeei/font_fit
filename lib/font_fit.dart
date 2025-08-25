 
import 'package:flutter/material.dart';

/// A drop-in replacement for [Text] that automatically scales
/// font size down (between [minFontSize] and [maxFontSize]) to fit
/// within the available width/lines, using a binary search for speed.
///
/// Typical usage:
/// ```dart
/// SafeText(
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
    // Establish defaults
    final defaultFontSize =
        style?.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14.0;

    // ignore: deprecated_member_use
    final mediaTextScale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0;
    final scale = respectTextScaleFactor ? mediaTextScale : 1.0;

    final double hiStart = (maxFontSize ?? defaultFontSize);
    final TextDirection textDir =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    return LayoutBuilder(
      builder: (context, constraints) {
        // If unconstrained width, just render normally.
        if (constraints.maxWidth.isInfinite) {
          return Text(
            data,
            style: style?.copyWith(fontSize: hiStart),
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          );
        }

        // Helper: does this font size fit in the box?
        bool fits(double fs) {
          final span = TextSpan(text: data, style: style?.copyWith(fontSize: fs));
          final tp = TextPainter(
            text: span,
            textAlign: textAlign,
            textDirection: textDir,
            maxLines: maxLines,
            ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
          )..layout(maxWidth: constraints.maxWidth);
          final widthOK = tp.width <= constraints.maxWidth + 0.01;
          final linesOK = !(tp.didExceedMaxLines);
          return widthOK && linesOK;
        }

        // Binary search between [minFontSize, hiStart]
        double lo = minFontSize.clamp(0.0, hiStart);
        double hi = hiStart;
        double best = lo;

        // Early exit: if even min fits, search upwards to find max fitting size.
        // But our goal is to render as close to hiStart as possible, so we just run one binary search.
        int safety = 0;
        while ((hi - lo) > precision && safety++ < 40) {
          final mid = (lo + hi) / 2;
          if (fits(mid * scale)) {
            best = mid;
            lo = mid; // try larger
          } else {
            hi = mid; // shrink
          }
        }

        // Ensure we don't exceed the requested "max" (hiStart), apply scale
        final chosen = (best).clamp(minFontSize, hiStart) * scale;

        return Text(
          data,
          style: style?.copyWith(fontSize: chosen),
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        );
      },
    );
  }
}
