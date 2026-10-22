import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_sheet.dart';
import 'package:snow_flow/features/settings/presentation/settings_page.dart';
import 'package:snow_flow/features/summary/presentation/summary_page.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/presentation/app_logo.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

import 'helpers/pump_app.dart';

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> goAndSettle(
  WidgetTester tester,
  GoRouter router,
  String location,
) async {
  router.go(location);
  await tester.pumpAndSettle();
}

final _bottomBarLabel = find.text('Entries');
final _settingsButton = find.byTooltip('Settings');
final _backButton = find.byTooltip('Back');

void main() {
  group('bottom bar', () {
    testWidgets('the summary tab shows the summary page', (tester) async {
      final router = await pumpSnowFlowApp(tester);

      await tapAndSettle(tester, find.text('Summary'));

      expect(find.byType(SummaryPage), findsOneWidget);
      expect(find.byType(EntriesPage), findsNothing);
      expect(router.state.matchedLocation, summaryPath);
    });

    testWidgets('the entries tab goes back, and the summary tab is kept', (
      tester,
    ) async {
      final router = await pumpSnowFlowApp(tester);
      await tapAndSettle(tester, find.text('Summary'));

      await tapAndSettle(tester, _bottomBarLabel);

      expect(find.byType(EntriesPage), findsOneWidget);
      expect(router.state.matchedLocation, entriesPath);
      expect(find.byType(SummaryPage, skipOffstage: false), findsOneWidget);
    });
  });

  group('header', () {
    testWidgets('the entries page shows the logo and SnowFlow', (tester) async {
      await pumpSnowFlowApp(tester);

      expect(find.byType(AppLogo), findsOneWidget);
      expect(find.text('SnowFlow'), findsOneWidget);
      expect(_settingsButton, findsOneWidget);
    });

    testWidgets('the summary page shows its name instead', (tester) async {
      await pumpSnowFlowApp(tester);
      await tapAndSettle(tester, find.text('Summary'));

      expect(find.byType(AppLogo), findsNothing);
      expect(find.text('SnowFlow'), findsNothing);
      // The title and the tab label.
      expect(find.text('Summary'), findsNWidgets(2));
      expect(_settingsButton, findsOneWidget);
    });
  });

  group('entries page', () {
    // Today, so the entry is in the current cycle whenever the test runs.
    final today = LocalDate.fromDateTime(DateTime.now());
    final lunch = Entry(
      id: 'lunch',
      type: EntryType.expense,
      amount: const Money(6050),
      currency: Currency.thb,
      category: Categories.food,
      date: today,
      note: 'Chicken rice',
      created: 1,
    );

    testWidgets('tapping an entry opens the form to edit it', (tester) async {
      await pumpSnowFlowApp(tester, entries: [lunch]);

      await tapAndSettle(tester, find.text('Chicken rice'));

      final sheet = tester.widget<EntryFormSheet>(find.byType(EntryFormSheet));
      expect(sheet.entry, lunch);
    });

    testWidgets('the other-currency note opens the summary tab (#12)', (
      tester,
    ) async {
      final router = await pumpSnowFlowApp(
        tester,
        entries: [
          lunch,
          lunch.copyWith(id: 'yen', currency: Currency.jpy),
        ],
      );

      await tapAndSettle(tester, find.textContaining('other currencies'));

      expect(find.byType(SummaryPage), findsOneWidget);
      expect(router.state.matchedLocation, summaryPath);
    });
  });

  group('settings', () {
    testWidgets('the gear opens settings without the bottom bar', (
      tester,
    ) async {
      final router = await pumpSnowFlowApp(tester);

      await tapAndSettle(tester, _settingsButton);

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(_bottomBarLabel, findsNothing);
      expect(router.state.matchedLocation, settingsPath);
      // The browser's address bar shows it too, so a refresh stays there.
      expect(router.routeInformationProvider.value.uri.path, settingsPath);
    });

    testWidgets('back returns to the tab it came from', (tester) async {
      final router = await pumpSnowFlowApp(tester);
      await tapAndSettle(tester, find.text('Summary'));
      await tapAndSettle(tester, _settingsButton);

      await tapAndSettle(tester, _backButton);

      expect(find.byType(SummaryPage), findsOneWidget);
      expect(router.state.matchedLocation, summaryPath);
    });

    testWidgets('opened straight from its URL, back goes to entries (#59 Q3)', (
      tester,
    ) async {
      final router = await pumpSnowFlowApp(tester);
      await goAndSettle(tester, router, settingsPath);
      expect(find.byType(SettingsPage), findsOneWidget);

      await tapAndSettle(tester, _backButton);

      expect(find.byType(EntriesPage), findsOneWidget);
      expect(router.state.matchedLocation, entriesPath);
    });
  });

  group('a URL without a route opens the entries page (#59 Q2)', () {
    for (final location in ['/abc', '/', '/settings/xyz']) {
      testWidgets(location, (tester) async {
        final router = await pumpSnowFlowApp(tester);
        await tapAndSettle(tester, find.text('Summary'));

        await goAndSettle(tester, router, location);

        expect(find.byType(EntriesPage), findsOneWidget);
        expect(router.state.matchedLocation, entriesPath);
      });
    }
  });

  group('add entry (#59 Q1)', () {
    testWidgets('opens the form over the current tab, which stays', (
      tester,
    ) async {
      final router = await pumpSnowFlowApp(tester);
      await tapAndSettle(tester, find.text('Summary'));

      await tapAndSettle(tester, find.text('Add entry'));

      expect(find.byType(EntryFormSheet), findsOneWidget);
      expect(router.state.matchedLocation, summaryPath);

      // Taps the scrim above the sheet.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(EntryFormSheet), findsNothing);
      expect(find.byType(SummaryPage), findsOneWidget);
    });

    testWidgets('the pencil button opens it too', (tester) async {
      await pumpSnowFlowApp(tester);

      await tapAndSettle(
        tester,
        find.byWidgetPredicate(
          (widget) => widget is LineIcon && widget.shapes == AppIcons.pencil,
        ),
      );

      expect(find.byType(EntryFormSheet), findsOneWidget);
    });
  });
}
