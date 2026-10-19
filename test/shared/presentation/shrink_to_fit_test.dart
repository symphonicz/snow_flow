import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/presentation/shrink_to_fit.dart';

const _longest = '฿99,999,999,999.99';
// The test font draws every character 1em wide: 3 × 44 × 1.3 fits in 320.
const _short = '¥60';
const _big = TextStyle(fontSize: 44);

Future<void> _pump(WidgetTester tester, String text) async {
  tester.view
    ..physicalSize = const Size(360, 640)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ShrinkToFit(child: Text(text, style: _big)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a long amount shrinks to fit at 360px with 1.3 text (#37)', (
    tester,
  ) async {
    await _pump(tester, _longest);

    expect(tester.takeException(), isNull);
    // Every digit is laid out on one line, wider than the space…
    final line = tester.renderObject<RenderParagraph>(find.text(_longest));
    expect(line.didExceedMaxLines, isFalse);
    expect(line.size.height, lessThan(44 * 1.3 * 1.5));
    expect(line.size.width, greaterThan(320));
    // …and the whole line is drawn smaller to fit, never cut with "…".
    expect(_drawnRect(tester, _longest).width, lessThanOrEqualTo(320));
  });

  testWidgets('a short amount keeps its size', (tester) async {
    await _pump(tester, _short);

    final line = tester.renderObject<RenderParagraph>(find.text(_short));
    expect(_drawnRect(tester, _short).width, closeTo(line.size.width, 0.01));
  });

  testWidgets('starts at the reading edge', (tester) async {
    await _pump(tester, _short);

    expect(_drawnRect(tester, _short).left, 20);
  });
}

/// Where [text] lands on screen, after any scaling.
Rect _drawnRect(WidgetTester tester, String text) =>
    tester.getRect(find.text(text));
