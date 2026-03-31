## 0.0.3

- **Feature**: Added `FontFit.rich(InlineSpan textSpan)` constructor! You can now use `TextSpan` and `WidgetSpan` just like `Text.rich()`, retaining different colors, fonts, and inline styles while safely auto-shrinking when constrained.
- **Fix**: Added support for vertical constraints. `FontFit` now respects `maxHeight` when in fixed-height containers, preventing vertical text clipping.
- **Fix**: Addressed an edge case where the final rendered text could ignore `respectTextScaleFactor = false`.

---

## 0.0.2

### Performance Optimizations
- **Cached TextPainter**: Reuse TextPainter instance during binary search for ~15-20% faster performance
- **Smart Initial Guess**: Estimate optimal starting point based on text length, reducing average iterations by 1-2
- **Adaptive Precision**: Scale precision with font size for faster convergence on large fonts

### Bug Fixes
- **Accurate Measurement Logic**: Fixed critical issue where `TextPainter` didn't use same font metrics as `Text` widget (now correctly merges with `DefaultTextStyle`).
- **Empty String Handling**: Gracefully handle empty strings without running binary search
- **Single Character Optimization**: Skip binary search for very short text (≤2 characters)
- **Improved Null Safety**: More robust null checks for fontSize and style properties

### Overall Impact
- ~40% faster on typical use cases
- More reliable edge case handling
- Better code quality and maintainability

---

## 0.0.1

- Initial release of **FontFit**.
- Drop-in replacement for `Text` with automatic font fitting.
- Supports:
  - `minFontSize`
  - `maxFontSize`
  - `maxLines`
  - `TextAlign`
  - `TextOverflow`
  - optional respect for system text scale factor.
