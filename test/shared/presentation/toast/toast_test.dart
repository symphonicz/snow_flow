import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

/// An app with a button that shows a toast, like a feature would.
Future<void> pumpApp(
  WidgetTester tester, {
  required void Function(BuildContext context) onPressed,
  ThemeMode mode = ThemeMode.light,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      locale: locale,
      supportedLocales: appLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => ToastHost(child: child!),
      // Centred so the toast at the top never covers the button.
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => onPressed(context),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> tapShow(WidgetTester tester) async {
  await tester.tap(find.text('show'));
  await tester.pumpAndSettle();
}

BoxDecoration toastBox(WidgetTester tester, String message) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.text(message),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

Color textColor(WidgetTester tester, String message) =>
    tester.renderObject<RenderParagraph>(find.text(message)).text.style!.color!;

List<IconShape> toastIcon(WidgetTester tester) => tester
    .widget<LineIcon>(
      find
          .descendant(
            of: find.byType(ToastHost),
            matching: find.byType(LineIcon),
          )
          .first,
    )
    .shapes;

void main() {
  group('the three kinds (#20)', () {
    testWidgets('success: income, check icon, gone after 4 seconds', (
      tester,
    ) async {
      await pumpApp(
        tester,
        onPressed: (context) => showToast(context, 'Saved'),
      );
      await tapShow(tester);

      expect(find.text('Saved'), findsOneWidget);
      expect(toastBox(tester, 'Saved').color, const Color(0xFF0B7A63));
      expect(textColor(tester, 'Saved'), const Color(0xFFFFFFFF));
      expect(toastIcon(tester), AppIcons.circleCheck);
      expect(find.text('Try again'), findsNothing);

      await tester.pump(const Duration(milliseconds: 3900));
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('error: expense, alert icon, try again, gone after 6 seconds', (
      tester,
    ) async {
      var retries = 0;
      await pumpApp(
        tester,
        onPressed: (context) => showToast(
          context,
          'Export failed',
          kind: ToastKind.error,
          onRetry: () => retries++,
        ),
      );
      await tapShow(tester);

      expect(toastBox(tester, 'Export failed').color, const Color(0xFFB93E0B));
      expect(textColor(tester, 'Export failed'), const Color(0xFFFFFFFF));
      expect(toastIcon(tester), AppIcons.circleAlert);

      await tester.pump(const Duration(milliseconds: 5900));
      expect(find.text('Export failed'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Export failed'), findsNothing);
      expect(retries, 0);
    });

    testWidgets('info: brand, info icon, gone after 4 seconds', (tester) async {
      await pumpApp(
        tester,
        onPressed: (context) =>
            showToast(context, 'Nothing to export', kind: ToastKind.info),
      );
      await tapShow(tester);

      expect(
        toastBox(tester, 'Nothing to export').color,
        const Color(0xFF1F5F75),
      );
      expect(textColor(tester, 'Nothing to export'), const Color(0xFFFFFFFF));
      expect(toastIcon(tester), AppIcons.info);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Nothing to export'), findsNothing);
    });

    testWidgets('dark theme uses the dark tokens with dark text', (
      tester,
    ) async {
      await pumpApp(
        tester,
        mode: ThemeMode.dark,
        onPressed: (context) =>
            showToast(context, 'Export failed', kind: ToastKind.error),
      );
      await tapShow(tester);

      expect(toastBox(tester, 'Export failed').color, const Color(0xFFF2905F));
      expect(textColor(tester, 'Export failed'), const Color(0xFF0C1F27));
    });

    testWidgets('a soft shadow and md corners instead of a border', (
      tester,
    ) async {
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tapShow(tester);

      final box = toastBox(tester, 'Hi');
      expect(box.border, isNull);
      expect(box.borderRadius, BorderRadius.circular(14));
      expect(box.boxShadow, isNotEmpty);
    });
  });

  group('closing', () {
    testWidgets('try again closes the toast and calls back', (tester) async {
      var retries = 0;
      await pumpApp(
        tester,
        onPressed: (context) => showToast(
          context,
          'Export failed',
          kind: ToastKind.error,
          onRetry: () => retries++,
        ),
      );
      await tapShow(tester);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(retries, 1);
      expect(find.text('Export failed'), findsNothing);
    });

    testWidgets('✕ closes it', (tester) async {
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tapShow(tester);

      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Hi'), findsNothing);
    });

    testWidgets('swiping up closes it on mobile', (tester) async {
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tapShow(tester);

      await tester.fling(find.text('Hi'), const Offset(0, -200), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Hi'), findsNothing);
    });

    testWidgets('a new toast replaces the old one at once', (tester) async {
      var count = 0;
      await pumpApp(
        tester,
        onPressed: (context) => showToast(context, 'Toast ${++count}'),
      );
      await tapShow(tester);
      await tester.pump(const Duration(seconds: 3));

      await tapShow(tester);
      expect(find.text('Toast 1'), findsNothing);
      expect(find.text('Toast 2'), findsOneWidget);

      // The new one gets its own full 4 seconds.
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Toast 2'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Toast 2'), findsNothing);
    });
  });

  group('placement', () {
    void setWidth(WidgetTester tester, double width) {
      tester.view
        ..physicalSize = Size(width, 800)
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(top: 24);
      addTearDown(tester.view.reset);
    }

    testWidgets('mobile: top, below the safe area, 12 from each side', (
      tester,
    ) async {
      setWidth(tester, 360);
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tapShow(tester);

      final rect = tester.getRect(
        find
            .ancestor(of: find.text('Hi'), matching: find.byType(DecoratedBox))
            .first,
      );
      expect(rect.top, 24 + 12);
      expect(rect.left, 12);
      expect(rect.right, 360 - 12);
    });

    testWidgets('web: top right corner, at most 320 wide', (tester) async {
      setWidth(tester, 1280);
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tapShow(tester);

      final rect = tester.getRect(
        find
            .ancestor(of: find.text('Hi'), matching: find.byType(DecoratedBox))
            .first,
      );
      expect(rect.top, 24 + 20);
      expect(rect.right, 1280 - 20);
      expect(rect.width, 320);
    });

    testWidgets('floats above dialogs', (tester) async {
      await pumpApp(
        tester,
        onPressed: (context) {
          showDialog<void>(
            context: context,
            builder: (context) => const AlertDialog(content: Text('dialog')),
          );
          showToast(context, 'Hi');
        },
      );
      await tapShow(tester);

      // The ✕ is reachable, so nothing covers the toast.
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Hi'), findsNothing);
      expect(find.text('dialog'), findsOneWidget);
    });

    testWidgets('slides in, but not when the device reduces motion', (
      tester,
    ) async {
      await pumpApp(tester, onPressed: (context) => showToast(context, 'Hi'));
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();
      final settled = tester.getTopLeft(find.text('Hi'));

      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('show'));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Hi')), isNot(settled));
      await tester.pumpAndSettle();

      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pump();
      await tester.tap(find.text('show'));
      await tester.pump();
      expect(tester.getTopLeft(find.text('Hi')), settled);
    });
  });

  testWidgets('asks the screen reader to read the message', (tester) async {
    final announced = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      (message) async {
        announced.add(message);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(
            SystemChannels.accessibility,
            null,
          ),
    );
    await pumpApp(tester, onPressed: (context) => showToast(context, 'Saved'));
    await tapShow(tester);

    expect(
      announced,
      contains(
        predicate<Object?>(
          (message) =>
              message is Map &&
              message['type'] == 'announce' &&
              (message['data'] as Map)['message'] == 'Saved',
        ),
      ),
    );
  });

  testWidgets('Thai app language gets Thai buttons', (tester) async {
    await pumpApp(
      tester,
      locale: const Locale('th'),
      onPressed: (context) => showToast(
        context,
        'ส่งออกไม่สำเร็จ ลองอีกครั้ง',
        kind: ToastKind.error,
        onRetry: () {},
      ),
    );
    await tapShow(tester);

    expect(find.text('ลองอีกครั้ง'), findsOneWidget);
    expect(find.bySemanticsLabel('ปิด'), findsOneWidget);
  });

  for (final locale in const [Locale('th'), Locale('en')]) {
    testWidgets('no overflow at 360px with 1.3 text in $locale', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      await pumpApp(
        tester,
        locale: locale,
        onPressed: (context) => showToast(
          context,
          'ไฟล์นี้มาจาก SnowFlow รุ่นใหม่กว่า อัปเดตแอปก่อนนำเข้า '
          'This file comes from a newer SnowFlow, update the app first',
          kind: ToastKind.error,
          onRetry: () {},
        ),
      );
      await tapShow(tester);

      expect(tester.takeException(), isNull);
    });
  }
}
