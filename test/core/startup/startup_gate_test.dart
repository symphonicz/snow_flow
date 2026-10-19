import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_gate.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

import '../../helpers/fakes/fake_startup.dart';

const _app = Text('the app', textDirection: TextDirection.ltr);

void main() {
  late FakeTabLock tabLock;
  late FakeAppStorage storage;

  setUp(() {
    tabLock = FakeTabLock();
    storage = FakeAppStorage();
  });

  Future<StartupCubit> pumpGate(
    WidgetTester tester, {
    bool isWeb = true,
  }) async {
    final cubit = StartupCubit(tabLock: tabLock, storage: storage);
    addTearDown(cubit.close);
    await tester.pumpWidget(
      StartupGate(cubit: cubit, buildApp: () => _app, isWeb: isWeb),
    );
    await cubit.start();
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('opens the app when the storage is fine', (tester) async {
    await pumpGate(tester);

    expect(find.text('the app'), findsOneWidget);
  });

  group('data that cannot be read', () {
    setUp(() => storage.results.add(const StorageBroken({StoredData.entries})));

    testWidgets('shows the problem screen instead of the app', (tester) async {
      await pumpGate(tester);

      expect(find.text('the app'), findsNothing);
      expect(find.text("Can't read your data"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Start over (delete old data)'), findsOneWidget);
      expect(storage.startedOver, isEmpty);
    });

    testWidgets('try again opens the storage again', (tester) async {
      await pumpGate(tester);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(storage.openCount, 2);
      expect(find.text('the app'), findsOneWidget);
    });

    testWidgets('start over asks first; cancel deletes nothing', (
      tester,
    ) async {
      await pumpGate(tester);

      await tester.tap(find.text('Start over (delete old data)'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          "All entries will be deleted. Your settings stay. "
          "This can't be undone.",
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(storage.startedOver, isEmpty);
      expect(find.text("Can't read your data"), findsOneWidget);
    });

    testWidgets('start over deletes only the broken data once confirmed', (
      tester,
    ) async {
      await pumpGate(tester);

      await tester.tap(find.text('Start over (delete old data)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(storage.startedOver, [
        {StoredData.entries},
      ]);
      expect(find.text('the app'), findsOneWidget);
    });
  });

  group('storage that cannot be opened', () {
    setUp(() => storage.results.add(const StorageCannotOpen()));

    testWidgets('offers only try again, with a private window tip on web', (
      tester,
    ) async {
      await pumpGate(tester);

      expect(find.text("Can't open storage"), findsOneWidget);
      expect(find.textContaining('private window'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Start over (delete old data)'), findsNothing);
    });

    testWidgets('the app gets no private window tip', (tester) async {
      await pumpGate(tester, isWeb: false);

      expect(find.textContaining('private window'), findsNothing);
    });
  });

  group('more than one tab', () {
    testWidgets('the second tab is stopped with a message', (tester) async {
      tabLock.heldElsewhere = true;
      await pumpGate(tester);

      expect(find.text('SnowFlow is open in another tab'), findsOneWidget);
      expect(find.text('the app'), findsNothing);
      expect(storage.openCount, 0);
    });

    testWidgets('"use it here" takes over and opens the app', (tester) async {
      tabLock.heldElsewhere = true;
      await pumpGate(tester);

      await tester.tap(find.text('Use it in this tab instead'));
      await tester.pumpAndSettle();

      expect(tabLock.takeOvers, 1);
      expect(find.text('the app'), findsOneWidget);
    });

    testWidgets('the first tab leaves the app when another takes over', (
      tester,
    ) async {
      await pumpGate(tester);

      tabLock.loseToAnotherTab();
      await tester.pumpAndSettle();

      expect(find.text('the app'), findsNothing);
      expect(find.text('SnowFlow is open in another tab'), findsOneWidget);
      expect(storage.closeCount, 1);
    });
  });

  group('theme (#51)', () {
    testWidgets('follows the device brightness with the token themes', (
      tester,
    ) async {
      tabLock.heldElsewhere = true;
      await pumpGate(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, AppTheme.light);
      expect(app.darkTheme, AppTheme.dark);
      expect(app.themeMode, ThemeMode.system);
    });

    testWidgets('uses the app line icons', (tester) async {
      tabLock.heldElsewhere = true;
      await pumpGate(tester);

      expect(find.byType(Icon), findsNothing);
      expect(
        tester.widget<LineIcon>(find.byType(LineIcon)).shapes,
        AppIcons.appWindow,
      );
    });

    testWidgets('the delete buttons use the expense colour', (tester) async {
      storage.results.add(const StorageBroken({StoredData.entries}));
      await pumpGate(tester);
      Color? colorOf(String label) => tester
          .widget<TextButton>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(TextButton),
            ),
          )
          .style!
          .foregroundColor!
          .resolve({});

      expect(colorOf('Start over (delete old data)'), const Color(0xFFB93E0B));
      await tester.tap(find.text('Start over (delete old data)'));
      await tester.pumpAndSettle();
      expect(colorOf('Delete'), const Color(0xFFB93E0B));
    });
  });

  testWidgets('a Thai device gets Thai text', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('th', 'TH')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tabLock.heldElsewhere = true;

    await pumpGate(tester);

    expect(find.text('SnowFlow เปิดอยู่ในแท็บอื่น'), findsOneWidget);
    expect(find.text('ใช้ที่แท็บนี้แทน'), findsOneWidget);
  });

  // Until the shared overflow helper of #59 exists: 360px wide, large text.
  for (final locale in const [Locale('th'), Locale('en')]) {
    testWidgets('no overflow at 360px with 1.3 text in $locale', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      tester.platformDispatcher
        ..localesTestValue = [locale]
        ..textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);
      storage.results.addAll([
        const StorageBroken({StoredData.entries, StoredData.settings}),
        const StorageCannotOpen(),
      ]);

      final cubit = await pumpGate(tester);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await cubit.retry();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      tabLock.loseToAnotherTab();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
