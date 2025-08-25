# FontFit

A drop-in replacement for Flutter’s [`Text`](https://api.flutter.dev/flutter/widgets/Text-class.html) widget that automatically scales its font size down to fit within the available width/lines.  
It uses a fast binary search to find the largest font size that still fits the box.

---

## ✨ Features

- Keeps your text inside its box without overflowing.
- Configurable `minFontSize`, `maxFontSize`, and `maxLines`.
- Honors `TextAlign`, `TextOverflow`, and (optionally) the system text scale factor.
- Works just like `Text` — easy to swap in.

---

## 📦 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  font_fit: ^0.0.1

Run:

flutter pub get

Import it:

import 'package:font_fit/font_fit.dart';

Usage:

FontFit(
  'Very long text that needs to shrink',
  style: const TextStyle(fontSize: 24),
  minFontSize: 10,
  maxLines: 1,
)

FontFit will try to render the text at the provided style size (24 in this example), and shrink down until it fits (but never below minFontSize).