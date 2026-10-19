/// The overflow rule of #37 Q5, reusable by every screen's test: nothing may
/// overflow at 360 and 1280 px wide, in Thai and English, at text scale 1.0
/// and 1.3, in the light theme. The dark theme changes only colours, so it
/// gets one short case that just checks the screen opens without an error.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/theme/app_theme.dart';

/// One screen size, language, text scale and brightness to check.
class OverflowCase {
  const OverflowCase({
    required this.width,
    required this.locale,
    required this.textScale,
    this.brightness = Brightness.light,
  });

  final double width;
  final Locale locale;
  final double textScale;
  final Brightness brightness;

  /// A short phone for 360 wide, a laptop screen for 1280.
  double get height => width < AppSizes.webBreakpoint ? 740 : 800;

  @override
  String toString() =>
      '${width.toInt()}px ${locale.languageCode} ×$textScale ${brightness.name}';
}

/// Every light case of #37 Q5.
final overflowCases = [
  for (final width in [360.0, 1280.0])
    for (final locale in const [Locale('th'), Locale('en')])
      for (final textScale in [1.0, 1.3])
        OverflowCase(width: width, locale: locale, textScale: textScale),
];

/// The short dark-theme check.
const darkCases = [
  OverflowCase(
    width: 360,
    locale: Locale('th'),
    textScale: 1,
    brightness: Brightness.dark,
  ),
];

/// Sets the screen of [c] for the rest of the test. The language is left to
/// the caller, because each app picks it in its own way.
Future<void> applyCase(WidgetTester tester, OverflowCase c) async {
  tester.view
    ..physicalSize = Size(c.width, c.height)
    ..devicePixelRatio = 1;
  tester.platformDispatcher
    ..textScaleFactorTestValue = c.textScale
    ..platformBrightnessTestValue = c.brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

/// Fails when anything overflowed (or threw) since the last check.
void expectNoOverflow(WidgetTester tester) {
  final error = tester.takeException();
  expect(error, isNull, reason: 'the screen overflowed or threw: $error');
}

/// One test per case in [cases] (default [overflowCases]): [pump] shows the
/// screen for the case, then nothing may have overflowed.
void testNoOverflow(
  String description,
  Future<void> Function(WidgetTester tester, OverflowCase c) pump, {
  List<OverflowCase>? cases,
}) {
  for (final c in cases ?? overflowCases) {
    testWidgets('$description fits at $c', (tester) async {
      await applyCase(tester, c);
      await pump(tester, c);
      expectNoOverflow(tester);
    });
  }
}
