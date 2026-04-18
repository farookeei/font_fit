import 'package:flutter/material.dart';

/// A drop-in replacement for [Text] that automatically scales
/// font size down (between [minFontSize] and [maxFontSize]) to fit
/// within the available width/lines, using a binary search for speed.
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
  /// The text to display.
  ///
  /// Used in the default constructor. For [InlineSpan] support,
  /// use [FontFit.rich].
  final String? data;

  /// The text to display as an [InlineSpan].
  ///
  /// Used in the [FontFit.rich] constructor.
  final InlineSpan? textSpan;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's fontSize is null, it will fall back to
  /// [DefaultTextStyle].
  final TextStyle? style;

  /// The smallest allowed font size.
  ///
  /// Defaults to 10. The font size will never scale below this value,
  /// even if the text overflows.
  final double minFontSize;

  /// The largest allowed font size.
  ///
  /// Defaults to the incoming [style.fontSize] (or [DefaultTextStyle]),
  /// which is what most people expect: "try to render at this size,
  /// but shrink if needed."
  final double? maxFontSize;

  /// The maximum number of lines for the text to span.
  ///
  /// If the text exceeds this limit, the font size will be reduced.
  /// If null, the text can grow vertically indefinitely.
  final int? maxLines;

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The precision of the font size calculation.
  ///
  /// The binary search will stop when the difference between
  /// high and low bounds is less than this value. Defaults to 0.25.
  final double precision;

  /// Whether to honor the system [MediaQuery.textScaleFactor].
  ///
  /// Defaults to true. If false, the text will ignore the system
  /// font scaling settings.
  final bool respectTextScaleFactor;

  /// Creates a [FontFit] widget that displays a [String].
  ///
  /// The [data] parameter must not be null.
  const FontFit(
    String this.data, {
    super.key,
    this.style,
    this.minFontSize = 10,
    this.maxFontSize,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.precision = 0.25,
    this.respectTextScaleFactor = true,
  }) : textSpan = null;

  /// Creates a [FontFit] widget that displays an [InlineSpan].
  ///
  /// Useful for rich text with multiple styles.
  const FontFit.rich(
    InlineSpan this.textSpan, {
    super.key,
    this.style,
    this.minFontSize = 10,
    this.maxFontSize,
    this.maxLines,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.precision = 0.25,
    this.respectTextScaleFactor = true,
  }) : data = null;

  @override
  Widget build(BuildContext context) {
    final bool isRich = textSpan != null;
    final int textLength = isRich
        ? textSpan!.toPlainText().length
        : data!.length;

    if (textLength == 0 && !isRich) {
      return Text(
        data!,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
      );
    }

    // Fix: Merge with DefaultTextStyle to ensure we measure with the correct font family/weight
    // The Text widget does this internally, so we must do it manually for TextPainter to match.
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = style == null
        ? defaultTextStyle
        : defaultTextStyle.merge(style);

    // ignore: deprecated_member_use
    final mediaTextScale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1.0;
    final scale = respectTextScaleFactor ? mediaTextScale : 1.0;

    final double hiStart =
        maxFontSize ??
        effectiveStyle.fontSize ??
        defaultTextStyle.fontSize ??
        14.0;

    final TextDirection textDir =
        Directionality.maybeOf(context) ?? TextDirection.ltr;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth.isInfinite) {
          if (isRich) {
            return Text.rich(
              textSpan!,
              style: effectiveStyle.copyWith(fontSize: hiStart),
              maxLines: maxLines,
              textAlign: textAlign,
              overflow: overflow,
              // ignore: deprecated_member_use
              textScaleFactor: respectTextScaleFactor ? null : 1.0,
            );
          } else {
            return Text(
              data!,
              style: effectiveStyle.copyWith(fontSize: hiStart),
              maxLines: maxLines,
              textAlign: textAlign,
              overflow: overflow,
              // ignore: deprecated_member_use
              textScaleFactor: respectTextScaleFactor ? null : 1.0,
            );
          }
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
          if (isRich) {
            final scaleMultiplier = fs / hiStart;
            painter.text = TextSpan(
              style: effectiveStyle,
              children: [textSpan!],
            );
            // ignore: deprecated_member_use
            painter.textScaleFactor = scaleMultiplier * scale;
          } else {
            painter.text = TextSpan(
              text: data,
              style: effectiveStyle.copyWith(fontSize: fs),
            );
            // ignore: deprecated_member_use
            painter.textScaleFactor = scale;
          }
          painter.layout(maxWidth: constraints.maxWidth);
          final widthOK = painter.width <= constraints.maxWidth + 0.01;
          final linesOK = !(painter.didExceedMaxLines);
          final heightOK = constraints.hasBoundedHeight
              ? painter.height <= constraints.maxHeight + 0.01
              : true;
          return widthOK && linesOK && heightOK;
        }

        if (!isRich && textLength <= 2) {
          final testSize = hiStart;
          if (fits(testSize)) {
            // Note: 'fits' scales internally using `scale`. We don't need to pass `* scale`
            // Wait, previous code checked `fits(testSize * scale)`. 'fits' multiplies `fs` by `scale` indirectly if not rich?
            // Ah, previously it was: `style: ...copyWith(fontSize: fs)`. And `fs` was `mid * scale`.
            // Now `fees(testSize)` applies `fontSize: testSize` and `textScaleFactor: scale`.
            // This is equivalent!
            painter.dispose();
            return Text(
              data!,
              style: effectiveStyle.copyWith(fontSize: testSize),
              maxLines: maxLines,
              textAlign: textAlign,
              overflow: overflow,
              // ignore: deprecated_member_use
              textScaleFactor: respectTextScaleFactor ? null : 1.0,
            );
          }
        }

        final adaptivePrecision = (hiStart * 0.01).clamp(0.1, precision);

        double lo = minFontSize.clamp(0.0, hiStart);
        double hi = hiStart;
        double best = lo;

        final estimatedCharWidth = hiStart * 0.6;
        final estimatedTotalWidth = textLength * estimatedCharWidth;

        if (estimatedTotalWidth > constraints.maxWidth) {
          final smartGuess =
              (constraints.maxWidth / (textLength == 0 ? 1 : textLength) / 0.6)
                  .clamp(minFontSize, hiStart);

          // We pass smartGuess directly to fits() since fits() no longer expects pre-scaled test sizes
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

        // Clean up
        painter.dispose();

        // Calculate final chosen size (unscaled, because Text widget scales it)
        final chosen = (best).clamp(minFontSize, hiStart);

        if (isRich) {
          final chosenScaleMultiplier = chosen / hiStart;
          final finalScale = chosenScaleMultiplier * scale;

          return Text.rich(
            textSpan!,
            style: effectiveStyle,
            // ignore: deprecated_member_use
            textScaleFactor: finalScale,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
          );
        } else {
          return Text(
            data!,
            style: effectiveStyle.copyWith(fontSize: chosen),
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: overflow,
            // ignore: deprecated_member_use
            textScaleFactor: respectTextScaleFactor ? null : 1.0,
          );
        }
      },
    );
  }
}
