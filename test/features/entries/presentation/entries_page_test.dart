import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entries/presentation/entries_cubit.dart';
import 'package:snow_flow/features/entries/presentation/entries_page.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

import '../../../helpers/fakes/controlled_entry_repository.dart';
import '../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../helpers/fakes/in_memory_settings_repository.dart';
import '../../../helpers/overflow.dart';

final _today = LocalDate(2026, 10, 22);

var _ids = 0;

Entry _entry(
  EntryType type,
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
  EntryCategory? category,
  String note = '',
}) => Entry(
  id: 'e${_ids++}',
  type: type,
  amount: Money(minorUnits),
  currency: currency,
  category:
      category ??
      (type == EntryType.income ? Categories.salary : Categories.food),
  date: date,
  note: note,
  created: _ids,
);

/// What the page asked the app to open.
class _Opened {
  final entries = <Entry>[];
  var summary = 0;
}

/// The entries page alone, as the router shows it, over [entries].
Future<_Opened> _pumpPage(
  WidgetTester tester, {
  EntryRepository? entries,
  List<Entry> list = const [],
  AppSettings settings = const AppSettings(),
  Locale locale = const Locale('en'),
}) async {
  final opened = _Opened();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      supportedLocales: appLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => ToastHost(child: child!),
      home: Scaffold(
        body: BlocProvider(
          create: (_) => EntriesCubit(
            WatchEntries(entries ?? InMemoryEntryRepository(list)),
            WatchSettings(InMemorySettingsRepository(settings)),
            today: () => _today,
          )..start(),
          child: EntriesPage(
            onOpenEntry: (context, entry) => opened.entries.add(entry),
            onOpenSummary: (context) => opened.summary++,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return opened;
}

Finder _text(String text) => find.text(text, findRichText: true);

void main() {
  final salary = _entry(EntryType.income, 3000000, LocalDate(2026, 10, 1));
  final lunch = _entry(EntryType.expense, 6050, _today, note: 'Chicken rice');
  final coffee = _entry(
    EntryType.expense,
    4500,
    LocalDate(2026, 10, 21),
    category: Categories.fun,
  );

  group('balance card', () {
    testWidgets('shows the cycle balance in the default currency', (
      tester,
    ) async {
      await _pumpPage(tester, list: [salary, lunch, coffee]);

      expect(_text('Balance this month'), findsOneWidget);
      expect(_text('October 2026'), findsOneWidget);
      expect(_text('฿29,894.50'), findsOneWidget);
      expect(_text('฿30,000.00'), findsOneWidget);
      expect(_text('฿105.50'), findsOneWidget);
      expect(_text("1% of this month's income spent"), findsOneWidget);
    });

    testWidgets('a cycle start day other than 1 shows the range', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        list: [lunch],
        settings: const AppSettings(cycleStartDay: 25),
      );

      expect(_text('25 Sep – 24 Oct 2026'), findsOneWidget);
    });

    testWidgets('says so when the cycle has no income yet', (tester) async {
      await _pumpPage(tester, list: [lunch]);

      expect(_text('No income this month yet'), findsOneWidget);
      expect(_text('−฿60.50'), findsWidgets);
    });

    testWidgets('notes other currencies and opens the summary (#12)', (
      tester,
    ) async {
      final yen = _entry(
        EntryType.expense,
        50000,
        _today,
        currency: Currency.jpy,
      );
      final opened = await _pumpPage(tester, list: [lunch, yen]);

      final note = _text(
        'There are entries in other currencies too. '
        'See Summary',
      );
      expect(note, findsOneWidget);
      await tester.tap(note);
      expect(opened.summary, 1);
    });

    testWidgets('has no note without other currencies', (tester) async {
      await _pumpPage(tester, list: [lunch]);

      expect(find.textContaining('other currencies'), findsNothing);
    });
  });

  group('entries by day', () {
    testWidgets('heads each day with today, yesterday or its date', (
      tester,
    ) async {
      await _pumpPage(tester, list: [salary, lunch, coffee]);

      expect(_text('Today'), findsOneWidget);
      expect(_text('Yesterday'), findsOneWidget);
      expect(_text('Thu, 1 Oct'), findsOneWidget);
    });

    testWidgets('in Thai too', (tester) async {
      await _pumpPage(
        tester,
        list: [salary, lunch, coffee],
        locale: const Locale('th'),
      );

      expect(_text('วันนี้'), findsOneWidget);
      expect(_text('เมื่อวาน'), findsOneWidget);
      expect(_text('พฤหัสบดี 1 ต.ค.'), findsOneWidget);
    });

    testWidgets('shows the net of each day per currency', (tester) async {
      final refund = _entry(
        EntryType.income,
        10000,
        _today,
        category: Categories.other,
      );
      final yen = _entry(
        EntryType.expense,
        50000,
        _today,
        currency: Currency.jpy,
      );
      await _pumpPage(tester, list: [lunch, refund, yen]);

      // ฿100.00 − ฿60.50
      expect(_text('+฿39.50'), findsOneWidget);
      expect(_text('−¥500'), findsWidgets);
    });

    testWidgets('a row shows category, note and signed amount', (tester) async {
      await _pumpPage(tester, list: [salary, lunch]);

      expect(_text('Food'), findsOneWidget);
      expect(_text('Chicken rice'), findsOneWidget);
      expect(_text('Salary'), findsOneWidget);
      expect(_text('+฿30,000.00'), findsWidgets);
    });

    testWidgets('tapping a row opens it for editing', (tester) async {
      final opened = await _pumpPage(tester, list: [salary, lunch]);

      await tester.tap(_text('Chicken rice'));
      expect(opened.entries, [lunch]);
    });

    testWidgets('no entry at all shows the card and how to start (#60 Q1)', (
      tester,
    ) async {
      await _pumpPage(tester);

      expect(_text('฿0.00'), findsWidgets);
      expect(_text('No entries yet. Tap Add entry to start'), findsOneWidget);
    });
  });

  group('read errors (#60 Q3)', () {
    testWidgets('a first read that fails says so and can try again', (
      tester,
    ) async {
      final entries = ControlledEntryRepository();
      await _pumpPage(tester, entries: entries);
      entries.stream.addError(const StorageUnreadable());
      await tester.pumpAndSettle();

      expect(_text("Couldn't read your entries"), findsOneWidget);
      await tester.tap(_text('Try again'));
      entries.stream.add([lunch]);
      await tester.pumpAndSettle();

      expect(_text('Chicken rice'), findsOneWidget);
    });

    testWidgets('a later one keeps the entries and shows a toast', (
      tester,
    ) async {
      final entries = ControlledEntryRepository();
      await _pumpPage(tester, entries: entries);
      entries.stream.add([lunch]);
      await tester.pumpAndSettle();
      entries.stream.addError(const StorageUnreadable());
      // The error reaches the page, then the toast slides in.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_text('Chicken rice'), findsOneWidget);
      expect(_text("Couldn't read your entries"), findsOneWidget);
      expect(_text('Try again'), findsOneWidget);
      // Lets the toast time out.
      await tester.pumpAndSettle(const Duration(seconds: 7));
    });
  });

  // #37: 100 of the largest entries add up to about ฿99,999,999,999 in the
  // card, with a 100-character note. Each day has a net in five
  // currencies, and one day is last year: Thursday has Thai's longest name.
  final note = ('ค่าน้ำค่าไฟและค่าอินเทอร์เน็ตรายเดือน ' * 3).characters
      .take(Entry.maxNoteLength)
      .toString();
  List<Entry> largest(EntryType type) => [
    for (var i = 0; i < 100; i++)
      _entry(
        type,
        Money.maxMinorUnits,
        LocalDate(2026, 10, 22 - i % 22),
        category: type == EntryType.income ? Categories.side : Categories.bills,
        note: note,
      ),
    for (final date in [_today, LocalDate(2025, 12, 25)])
      for (final currency in Currency.values.take(5))
        _entry(
          EntryType.expense,
          Money.maxMinorUnits,
          date,
          currency: currency,
          note: note,
        ),
  ];

  for (final (name, list) in [
    ('empty', <Entry>[]),
    ('full of income', largest(EntryType.income)),
    ('full of expense', largest(EntryType.expense)),
  ]) {
    Future<void> pump(WidgetTester tester, OverflowCase c) =>
        _pumpPage(tester, list: list, locale: c.locale);

    testNoOverflow('the entries page, $name,', pump);
    testNoOverflow(
      'the entries page, $name, in dark',
      pump,
      cases: darkCases,
    );
  }

  Future<void> pumpUnreadable(WidgetTester tester, OverflowCase c) async {
    final entries = ControlledEntryRepository();
    await _pumpPage(tester, entries: entries, locale: c.locale);
    entries.stream.addError(const StorageUnreadable());
    await tester.pumpAndSettle();
  }

  testNoOverflow('the unreadable message', pumpUnreadable);
  testNoOverflow(
    'the unreadable message in dark',
    pumpUnreadable,
    cases: darkCases,
  );

  testNoOverflow('the read error toast', (tester, c) async {
    final entries = ControlledEntryRepository();
    await _pumpPage(tester, entries: entries, locale: c.locale);
    entries.stream.add([lunch]);
    await tester.pumpAndSettle();
    entries.stream.addError(const StorageUnreadable());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expectNoOverflow(tester);
    await tester.pumpAndSettle(const Duration(seconds: 7));
  });
}
