import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

Widget _app(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: mode,
  home: Center(child: child),
);

// Plain colours: a MaterialColor never equals the Color a Paint returns.
const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);

void main() {
  final icons = {
    for (final category in Categories.all) category.id: category.icon,
    ...AppIcons.all,
  };

  for (final MapEntry(key: name, value: shapes) in icons.entries) {
    testWidgets('draws the $name icon as a 1.8 stroke', (tester) async {
      await tester.pumpWidget(_app(LineIcon(shapes, color: _red)));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(LineIcon)), const Size(24, 24));
      expect(
        find.byType(LineIcon),
        paints..something((method, arguments) {
          if (method != #drawPath) return false;
          final paint = arguments[1] as Paint;
          // Paint keeps a 32-bit float, so 1.8 comes back as 1.7999….
          return paint.style == PaintingStyle.stroke &&
              (paint.strokeWidth - 1.8).abs() < 1e-6 &&
              paint.strokeCap == StrokeCap.round &&
              paint.strokeJoin == StrokeJoin.round &&
              paint.color == _red;
        }),
      );
    });
  }

  for (final size in const [20.0, 48.0]) {
    testWidgets('keeps a 1.8 px stroke at $size px', (tester) async {
      await tester.pumpWidget(_app(LineIcon(AppIcons.pencil, size: size)));

      // The 24 grid is scaled to the size, so on the grid the stroke is
      // 1.8 × 24 / size to come out as 1.8 on screen.
      expect(
        find.byType(LineIcon),
        paints..something((method, arguments) {
          if (method != #drawPath) return false;
          final paint = arguments[1] as Paint;
          return (paint.strokeWidth - 1.8 * 24 / size).abs() < 1e-6;
        }),
      );
    });
  }

  testWidgets('stays centred when a parent stretches it, like Icon', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [LineIcon(AppIcons.close, size: 48)],
          ),
        ),
      ),
    );

    final box = tester.getRect(find.byType(LineIcon));
    final paint = tester.getRect(find.byType(CustomPaint).last);
    expect(paint.size, const Size(48, 48));
    expect(paint.center, box.center);
  });

  test('the app has every icon #51 and #59 ask for', () {
    expect(AppIcons.all.keys, {
      'entries',
      'summary',
      'back',
      'chevronDown',
      'calendar',
      'clock',
      'pencil',
      'settings',
      'lock',
      'circleCheck',
      'circleAlert',
      'info',
      'close',
      'appWindow',
      'database',
    });
  });

  testWidgets('takes its size and colour from the icon theme by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const IconTheme(
          data: IconThemeData(size: 20, color: _blue),
          child: LineIcon(AppIcons.pencil),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LineIcon)), const Size(20, 20));
    expect(find.byType(LineIcon), paints..path(color: _blue));
  });

  testWidgets('a semantic label is read out', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(const LineIcon(AppIcons.settings, semanticLabel: 'Settings')),
    );

    expect(find.bySemanticsLabel('Settings'), findsOneWidget);
    semantics.dispose();
  });

  group('CategoryIcon', () {
    testWidgets('uses the light colour of the category', (tester) async {
      await tester.pumpWidget(_app(const CategoryIcon(Categories.salary)));

      expect(
        find.byType(LineIcon),
        paints..path(color: const Color(0xFF0B7A63)),
      );
    });

    testWidgets('uses the dark colour in the dark theme', (tester) async {
      await tester.pumpWidget(
        _app(const CategoryIcon(Categories.salary), mode: ThemeMode.dark),
      );

      expect(
        find.byType(LineIcon),
        paints..path(color: const Color(0xFF4CC3A6)),
      );
    });
  });
}
