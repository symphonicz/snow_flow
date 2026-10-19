import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'overflow.dart';

Widget _app(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  test('covers 360/1280 × Thai/English × text scale 1.0/1.3 in light', () {
    final expected = {
      for (final width in [360.0, 1280.0])
        for (final lang in ['th', 'en'])
          for (final scale in [1.0, 1.3]) '$width $lang $scale light',
    };
    String key(OverflowCase c) =>
        '${c.width} ${c.locale.languageCode} ${c.textScale} ${c.brightness.name}';

    expect(overflowCases.map(key).toSet(), expected);
    expect(overflowCases, hasLength(8));
  });

  test('dark covers one short case', () {
    expect(darkCases, isNotEmpty);
    expect(darkCases.every((c) => c.brightness == Brightness.dark), isTrue);
  });

  testWidgets('a case sets the width, text scale and brightness', (
    tester,
  ) async {
    const c = OverflowCase(
      width: 360,
      locale: Locale('th'),
      textScale: 1.3,
      brightness: Brightness.dark,
    );
    await applyCase(tester, c);
    late MediaQueryData media;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) {
            media = MediaQuery.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(media.size.width, 360);
    expect(media.textScaler.scale(10), closeTo(13, 1e-9));
    expect(media.platformBrightness, Brightness.dark);
  });

  testWidgets('fails when a row overflows', (tester) async {
    await applyCase(tester, overflowCases.first);
    await tester.pumpWidget(
      _app(const Row(children: [SizedBox(width: 400, height: 10)])),
    );

    expect(() => expectNoOverflow(tester), throwsA(isA<TestFailure>()));
  });

  testWidgets('passes when long text wraps', (tester) async {
    await applyCase(tester, overflowCases.first);
    await tester.pumpWidget(_app(Text('ข้อความยาวมาก ' * 40)));

    expectNoOverflow(tester);
  });
}
