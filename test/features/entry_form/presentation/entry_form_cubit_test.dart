import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/add_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/delete_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/update_entry.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_cubit.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

import '../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../helpers/fakes/in_memory_settings_repository.dart';
import '../../../helpers/fixtures/entries.dart';

class _MockEntryRepository extends Mock implements EntryRepository {}

final _today = LocalDate(2026, 10, 22);
const _now = 1792000000000;

/// A started form over [entries]; [entry] to edit, or a new one.
Future<EntryFormCubit> _form(
  EntryRepository entries, {
  Entry? entry,
  AppSettings settings = const AppSettings(),
}) async {
  final cubit = EntryFormCubit(
    AddEntry(entries),
    UpdateEntry(entries),
    DeleteEntry(entries),
    GetDefaultCurrency(entries, InMemorySettingsRepository(settings)),
    entry: entry,
    today: () => _today,
    now: () => _now,
    newId: () => 'new',
  );
  addTearDown(cubit.close);
  await cubit.start();
  return cubit;
}

void main() {
  setUpAll(() => registerFallbackValue(lunch));

  group('a new entry (brief §4.1)', () {
    test('starts as an expense of today in the first category', () async {
      final form = await _form(InMemoryEntryRepository());

      expect(form.state.type, EntryType.expense);
      expect(form.state.category, Categories.food);
      expect(form.state.date, _today);
      expect(form.state.amountText, '');
      expect(form.state.note, '');
      expect(form.state.isEditing, isFalse);
    });

    test('starts in the currency used last', () async {
      final form = await _form(
        InMemoryEntryRepository([salary, lunch]),
        settings: const AppSettings(currency: Currency.eur),
      );

      expect(form.state.currency, Currency.thb);
    });

    test('starts in the settings currency with no entry yet', () async {
      final form = await _form(
        InMemoryEntryRepository(),
        settings: const AppSettings(currency: Currency.eur),
      );

      expect(form.state.currency, Currency.eur);
    });
  });

  group('changing a field', () {
    test('a type the category does not fit picks its first category', () async {
      final form = await _form(InMemoryEntryRepository());

      form.setType(EntryType.income);

      expect(form.state.type, EntryType.income);
      expect(form.state.category, Categories.salary);
    });

    test('other fits both types, so it stays', () async {
      final form = await _form(InMemoryEntryRepository());

      form
        ..setCategory(Categories.other)
        ..setType(EntryType.income);

      expect(form.state.category, Categories.other);
    });

    test('a currency without decimals cuts them off (#12)', () async {
      final form = await _form(InMemoryEntryRepository());

      form
        ..setAmount('1,200.50')
        ..setCurrency(Currency.jpy);

      expect(form.state.amountText, '1,200');
      expect(form.state.currency, Currency.jpy);
    });

    test('the date and the note are kept as given', () async {
      final form = await _form(InMemoryEntryRepository());

      form
        ..setDate(LocalDate(2026, 10, 1))
        ..setNote('ค่ารถ');

      expect(form.state.date, LocalDate(2026, 10, 1));
      expect(form.state.note, 'ค่ารถ');
    });
  });

  group('saving', () {
    for (final amount in ['', '0', '0.00', '0.']) {
      test('"$amount" asks for more than 0 and saves nothing', () async {
        final entries = InMemoryEntryRepository();
        final form = await _form(entries);

        form.setAmount(amount);
        await form.save();

        expect(form.state.showAmountError, isTrue);
        expect(form.state.status, EntryFormStatus.editing);
        expect((await entries.getAll()).getOrElse((_) => []), isEmpty);
      });
    }

    test('typing again hides the amount message', () async {
      final form = await _form(InMemoryEntryRepository());
      await form.save();

      form.setAmount('6');

      expect(form.state.showAmountError, isFalse);
    });

    test('adds a new entry with a trimmed note', () async {
      final entries = InMemoryEntryRepository();
      final form = await _form(entries);

      form
        ..setAmount('1,200.5')
        ..setNote('  ค่ารถ  ');
      await form.save();

      expect(form.state.status, EntryFormStatus.saved);
      expect((await entries.getAll()).getOrElse((_) => []), [
        Entry(
          id: 'new',
          type: EntryType.expense,
          amount: const Money(120050),
          currency: Currency.thb,
          category: Categories.food,
          date: _today,
          note: 'ค่ารถ',
          created: _now,
        ),
      ]);
    });

    test('an edit keeps the id and when it was created', () async {
      final entries = InMemoryEntryRepository([lunch]);
      final form = await _form(entries, entry: lunch);

      form.setAmount('75');
      await form.save();

      expect(form.state.status, EntryFormStatus.saved);
      expect((await entries.getAll()).getOrElse((_) => []), [
        lunch.copyWith(amount: const Money(7500)),
      ]);
    });

    test('an untouched amount stays exact, even one shown rounded', () async {
      // Imported with decimals; JPY shows ¥500 (#12).
      final yen = salary.copyWith(amount: const Money(50050));
      final entries = InMemoryEntryRepository([yen]);
      final form = await _form(entries, entry: yen);

      form.setNote('โบนัส');
      await form.save();

      expect((await entries.getAll()).getOrElse((_) => []), [
        yen.copyWith(note: 'โบนัส'),
      ]);
    });

    test('an entry deleted meanwhile is gone (#61 Q4)', () async {
      final form = await _form(InMemoryEntryRepository(), entry: lunch);

      await form.save();

      expect(form.state.status, EntryFormStatus.gone);
    });

    test('a storage error keeps the form and can try again', () async {
      final entries = _MockEntryRepository();
      when(entries.getAll).thenAnswer((_) async => const Right([]));
      when(
        () => entries.add(any()),
      ).thenAnswer((_) async => const Left(StorageUnavailable()));
      final form = await _form(entries);
      form.setAmount('60');

      await form.save();
      expect(form.state.status, EntryFormStatus.saveFailed);
      expect(form.state.amountText, '60');

      when(() => entries.add(any())).thenAnswer((_) async => const Right(unit));
      await form.save();
      expect(form.state.status, EntryFormStatus.saved);
    });

    test('is busy while saving, so a second tap adds nothing', () async {
      final entries = InMemoryEntryRepository();
      final form = await _form(entries);
      form.setAmount('60');

      final first = form.save();
      expect(form.state.status, EntryFormStatus.busy);
      await form.save();
      await first;

      expect((await entries.getAll()).getOrElse((_) => []), hasLength(1));
    });
  });

  group('deleting', () {
    test('removes the entry', () async {
      final entries = InMemoryEntryRepository([lunch, salary]);
      final form = await _form(entries, entry: lunch);

      await form.delete();

      expect(form.state.status, EntryFormStatus.deleted);
      expect((await entries.getAll()).getOrElse((_) => []), [salary]);
    });

    test('a storage error keeps the form', () async {
      final entries = _MockEntryRepository();
      when(
        () => entries.delete(any()),
      ).thenAnswer((_) async => const Left(StorageUnavailable()));
      final form = await _form(entries, entry: lunch);

      await form.delete();

      expect(form.state.status, EntryFormStatus.deleteFailed);
    });
  });

  group('editing an entry', () {
    test('starts from what it saved', () async {
      final form = await _form(InMemoryEntryRepository([lunch]), entry: lunch);

      expect(form.state.isEditing, isTrue);
      expect(form.state.type, EntryType.expense);
      expect(form.state.amountText, '60.50');
      expect(form.state.currency, Currency.thb);
      expect(form.state.category, Categories.food);
      expect(form.state.date, LocalDate(2026, 10, 3));
      expect(form.state.note, 'ข้าวมันไก่');
    });

    test('shows a whole amount in JPY and groups thousands', () async {
      final form = await _form(
        InMemoryEntryRepository([salary]),
        entry: salary,
      );

      expect(form.state.amountText, '30,000');
      expect(form.state.category, Categories.salary);
    });
  });
}
