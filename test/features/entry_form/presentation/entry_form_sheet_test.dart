import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_sheet.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

import '../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../helpers/fakes/in_memory_settings_repository.dart';
import '../../../helpers/fixtures/entries.dart';
import '../../../helpers/overflow.dart';
import '../../../helpers/pump_app.dart';

/// Opens the form over a blank page, as the add button or a tapped entry
/// does; [entry] to edit one. Returns where entries are saved.
Future<InMemoryEntryRepository> _openForm(
  WidgetTester tester, {
  Entry? entry,
  List<Entry> list = const [],
  AppSettings settings = const AppSettings(),
  Locale locale = const Locale('en'),
}) async {
  final entries = await useFakeDependencies(
    entries: list,
    settings: InMemorySettingsRepository(settings),
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: locale,
      supportedLocales: appLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => ToastHost(child: child!),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showEntryForm(context, entry: entry),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return entries;
}

Future<List<Entry>> _saved(InMemoryEntryRepository entries) async =>
    (await entries.getAll()).getOrElse((_) => []);

Finder get _amount => find.byKey(EntryFormSheet.amountKey);
Finder get _note => find.byKey(EntryFormSheet.noteKey);
Finder get _sheet => find.byType(EntryFormSheet);

Future<void> _tapSave(WidgetTester tester) async {
  await tester.tap(find.text('Save'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Lets a toast time out, so no timer is left when the test ends.
Future<void> _settleToast(WidgetTester tester) =>
    tester.pumpAndSettle(const Duration(seconds: 7));

LocalDate get _today => LocalDate.fromDateTime(DateTime.now());

/// The date field is below the fold of the test screen.
Future<void> _openDatePicker(WidgetTester tester) async {
  final field = find.byKey(EntryFormSheet.dateKey);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field);
}

void main() {
  group('a new entry', () {
    testWidgets('opens with the amount focused, as an expense of today', (
      tester,
    ) async {
      await _openForm(tester);

      expect(find.text('Add entry'), findsOneWidget);
      final amount = tester.widget<EditableText>(
        find.descendant(of: _amount, matching: find.byType(EditableText)),
      );
      expect(amount.focusNode.hasFocus, isTrue);
      expect(
        amount.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
      expect(find.text('Delete'), findsNothing);
      // The symbol shows even while the amount is empty (#61).
      expect(find.text('฿'), findsOneWidget);
    });

    testWidgets('asks for more than 0 and stays open', (tester) async {
      final entries = await _openForm(tester);

      await _tapSave(tester);

      expect(find.text('Enter an amount above 0'), findsOneWidget);
      expect(_sheet, findsOneWidget);
      expect(await _saved(entries), isEmpty);
    });

    testWidgets('saves, closes and says so (#61 Q4)', (tester) async {
      final entries = await _openForm(tester);

      await tester.enterText(_amount, '1200.5');
      await tester.pump();
      expect(find.text('1,200.5'), findsOneWidget);
      await tester.enterText(_note, ' Taxi ');
      await _tapSave(tester);

      expect(_sheet, findsNothing);
      expect(find.text('Entry saved'), findsOneWidget);
      final [saved] = await _saved(entries);
      expect(saved.type, EntryType.expense);
      expect(saved.amount, const Money(120050));
      expect(saved.currency, Currency.thb);
      expect(saved.category, Categories.food);
      expect(saved.date, _today);
      expect(saved.note, 'Taxi');
      await _settleToast(tester);
    });

    testWidgets('income shows the income categories', (tester) async {
      final entries = await _openForm(tester);

      await tester.tap(find.text('Income'));
      await tester.pump();
      expect(find.text('Food'), findsNothing);
      await tester.tap(find.text('Side income'));
      await tester.enterText(_amount, '500');
      await _tapSave(tester);

      final [saved] = await _saved(entries);
      expect(saved.type, EntryType.income);
      expect(saved.category, Categories.side);
      await _settleToast(tester);
    });

    testWidgets('starts in the currency used last and can change it', (
      tester,
    ) async {
      final entries = await _openForm(tester, list: [lunch]);

      expect(find.text('THB'), findsOneWidget);
      await tester.enterText(_amount, '500.5');
      await tester.tap(find.text('THB'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('JPY').last);
      await tester.pumpAndSettle();
      // JPY has no decimals (#12).
      expect(find.text('500'), findsOneWidget);
      await _tapSave(tester);

      final saved = (await _saved(entries)).firstWhere((e) => e != lunch);
      expect(saved.currency, Currency.jpy);
      expect(saved.amount, const Money(50000));
      await _settleToast(tester);
    });

    testWidgets('a note stops at 100 characters as people see them', (
      tester,
    ) async {
      await _openForm(tester);

      await tester.enterText(_note, 'ที่' * 120);
      await tester.pump();

      final note = tester.widget<EditableText>(
        find.descendant(of: _note, matching: find.byType(EditableText)),
      );
      expect(note.controller.text.characters.length, 100);
    });
  });

  group('the date picker (#61 Q2)', () {
    testWidgets('shows the Buddhist year in Thai and offers no later day', (
      tester,
    ) async {
      final entries = await _openForm(tester, locale: const Locale('th'));
      final year = DateTime.now().year;

      await _openDatePicker(tester);
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      final picker = find.byType(DatePickerDialog);
      expect(
        find.descendant(
          of: picker,
          matching: find.textContaining('${year + 543}'),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(of: picker, matching: find.textContaining('$year')),
        findsNothing,
      );
      final dialog = tester.widget<DatePickerDialog>(picker);
      expect(dialog.lastDate, DateUtils.dateOnly(DateTime.now()));

      await tester.tap(find.descendant(of: picker, matching: find.text('1')));
      await tester.tap(find.text('ตกลง'));
      await tester.pumpAndSettle();
      await tester.enterText(_amount, '60');
      await tester.tap(find.text('บันทึก'));
      await tester.pump();

      final [saved] = await _saved(entries);
      expect(saved.date, LocalDate(_today.year, _today.month, 1));
      await _settleToast(tester);
    });

    testWidgets('an imported future day stays, but the picker opens today', (
      tester,
    ) async {
      final future = lunch.copyWith(date: _today.nextDay);
      await _openForm(tester, list: [future], entry: future);

      await _openDatePicker(tester);
      await tester.pumpAndSettle();

      final dialog = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(dialog.initialDate, DateUtils.dateOnly(DateTime.now()));
    });
  });

  group('editing', () {
    testWidgets('shows what was saved and saves the changes', (tester) async {
      final entries = await _openForm(tester, list: [lunch], entry: lunch);

      expect(find.text('Edit entry'), findsOneWidget);
      expect(find.text('60.50'), findsOneWidget);
      expect(find.text('ข้าวมันไก่'), findsOneWidget);
      expect(find.text('3 Oct 2026'), findsOneWidget);
      await tester.enterText(_amount, '75');
      await _tapSave(tester);

      expect(await _saved(entries), [
        lunch.copyWith(amount: const Money(7500)),
      ]);
      expect(find.text('Entry saved'), findsOneWidget);
      await _settleToast(tester);
    });

    testWidgets('an entry deleted meanwhile closes and says so', (
      tester,
    ) async {
      await _openForm(tester, entry: lunch);

      await _tapSave(tester);

      expect(_sheet, findsNothing);
      expect(find.text('This entry was already deleted'), findsOneWidget);
      await _settleToast(tester);
    });
  });

  group('deleting (#61 Q5)', () {
    testWidgets('asks first, naming the saved entry', (tester) async {
      final entries = await _openForm(tester, list: [lunch], entry: lunch);
      await tester.enterText(_amount, '75');

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this entry?'), findsOneWidget);
      expect(find.text('Food −฿60.50 · 3 Oct 2026'), findsOneWidget);
      expect(find.text("You can't undo this."), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_sheet, findsOneWidget);
      expect(find.text('75'), findsOneWidget);
      expect(await _saved(entries), [lunch]);
    });

    testWidgets('deletes, closes and says so', (tester) async {
      final entries = await _openForm(tester, list: [lunch], entry: lunch);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_sheet, findsNothing);
      expect(find.text('Entry deleted'), findsOneWidget);
      expect(await _saved(entries), isEmpty);
      await _settleToast(tester);
    });
  });

  testWidgets('the entries page shows a new entry at once (brief §12)', (
    tester,
  ) async {
    await pumpSnowFlowApp(tester);

    await tester.tap(find.text('Add entry'));
    await tester.pumpAndSettle();
    await tester.enterText(_amount, '60');
    await _tapSave(tester);
    await _settleToast(tester);

    expect(find.text('−฿60.00'), findsWidgets);
  });

  // #37: the largest amount and a 100-character note, in the longest
  // category names.
  final note = ('ค่าน้ำค่าไฟและค่าอินเทอร์เน็ตรายเดือน ' * 3).characters
      .take(Entry.maxNoteLength)
      .toString();
  final largest = lunch.copyWith(
    amount: const Money(Money.maxMinorUnits),
    category: Categories.bills,
    note: note,
  );

  Future<void> pumpNew(WidgetTester tester, OverflowCase c) async {
    await _openForm(tester, locale: c.locale);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
  }

  Future<void> pumpEdit(WidgetTester tester, OverflowCase c) =>
      _openForm(tester, list: [largest], entry: largest, locale: c.locale);

  Future<void> pumpDelete(WidgetTester tester, OverflowCase c) async {
    await pumpEdit(tester, c);
    await tester.tap(
      find.text(c.locale.languageCode == 'th' ? 'ลบ' : 'Delete'),
    );
    await tester.pumpAndSettle();
  }

  testNoOverflow('the new entry form with its message', pumpNew);
  testNoOverflow('the new entry form in dark', pumpNew, cases: darkCases);
  testNoOverflow('the edit form at the largest amount', pumpEdit);
  testNoOverflow('the edit form in dark', pumpEdit, cases: darkCases);
  testNoOverflow('the delete dialog', pumpDelete);
  testNoOverflow('the delete dialog in dark', pumpDelete, cases: darkCases);
}
