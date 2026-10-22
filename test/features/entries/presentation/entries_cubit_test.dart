import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/features/entries/presentation/entries_cubit.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_repository.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

import '../../../helpers/fakes/controlled_entry_repository.dart';
import '../../../helpers/fakes/in_memory_entry_repository.dart';
import '../../../helpers/fakes/in_memory_settings_repository.dart';

var _ids = 0;

Entry _entry(
  EntryType type,
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
  int created = 0,
}) => Entry(
  id: 'e${_ids++}',
  type: type,
  amount: Money(minorUnits),
  currency: currency,
  category: type == EntryType.income ? Categories.salary : Categories.food,
  date: date,
  created: created,
);

final _today = LocalDate(2026, 10, 22);

EntriesCubit _cubit(
  EntryRepository entries, {
  AppSettings settings = const AppSettings(),
  InMemorySettingsRepository? settingsRepository,
  LocalDate Function()? today,
}) => EntriesCubit(
  WatchEntries(entries),
  WatchSettings(settingsRepository ?? InMemorySettingsRepository(settings)),
  today: today ?? () => _today,
);

TypeMatcher<EntriesLoaded> _loaded() => isA<EntriesLoaded>();

void main() {
  test('shows nothing before the first read', () {
    final cubit = _cubit(InMemoryEntryRepository());
    addTearDown(cubit.close);

    expect(cubit.state, const EntriesLoading());
  });

  final salary = _entry(EntryType.income, 3000000, LocalDate(2026, 10, 1));
  final lunch = _entry(
    EntryType.expense,
    6050,
    LocalDate(2026, 10, 22),
    created: 2,
  );
  final coffee = _entry(
    EntryType.expense,
    4500,
    LocalDate(2026, 10, 22),
    created: 1,
  );
  final lastMonth = _entry(EntryType.expense, 99900, LocalDate(2026, 9, 30));

  blocTest<EntriesCubit, EntriesState>(
    'shows the balance of the current cycle and every day, newest first',
    build: () =>
        _cubit(InMemoryEntryRepository([salary, lunch, coffee, lastMonth])),
    act: (cubit) => cubit.start(),
    expect: () => [
      _loaded()
          .having((s) => s.today, 'today', _today)
          .having((s) => s.cycle, 'cycle', Cycle(2026, 10, startDay: 1))
          .having((s) => s.currency, 'currency', Currency.thb)
          .having(
            (s) => s.balance,
            'balance',
            const CurrencyTotals(income: Money(3000000), expense: Money(10550)),
          )
          .having((s) => s.hasOtherCurrencies, 'other currencies', false)
          .having((s) => [for (final day in s.days) day.date], 'days', [
            LocalDate(2026, 10, 22),
            LocalDate(2026, 10, 1),
            lastMonth.date,
          ])
          .having((s) => s.days.first.entries, 'entries of today', [
            lunch,
            coffee,
          ]),
    ],
  );

  blocTest<EntriesCubit, EntriesState>(
    'a cycle with no entry in the default currency shows zero',
    build: () => _cubit(InMemoryEntryRepository([lastMonth])),
    act: (cubit) => cubit.start(),
    expect: () => [
      _loaded().having(
        (s) => s.balance,
        'balance',
        const CurrencyTotals(income: Money(0), expense: Money(0)),
      ),
    ],
  );

  blocTest<EntriesCubit, EntriesState>(
    'no entry at all is an empty list, not an error (#60 Q1)',
    build: () => _cubit(InMemoryEntryRepository()),
    act: (cubit) => cubit.start(),
    expect: () => [_loaded().having((s) => s.days, 'days', isEmpty)],
  );

  group('other currencies (#12)', () {
    final yen = _entry(
      EntryType.expense,
      50000,
      LocalDate(2026, 10, 5),
      currency: Currency.jpy,
    );
    final oldYen = _entry(
      EntryType.expense,
      50000,
      LocalDate(2026, 9, 5),
      currency: Currency.jpy,
    );

    blocTest<EntriesCubit, EntriesState>(
      'are noted when the cycle has one',
      build: () => _cubit(InMemoryEntryRepository([lunch, yen])),
      act: (cubit) => cubit.start(),
      expect: () => [
        _loaded()
            .having((s) => s.hasOtherCurrencies, 'other currencies', true)
            .having(
              (s) => s.balance,
              'balance',
              const CurrencyTotals(income: Money(0), expense: Money(6050)),
            ),
      ],
    );

    blocTest<EntriesCubit, EntriesState>(
      'are noted even when the cycle has nothing in the default currency',
      build: () => _cubit(InMemoryEntryRepository([yen])),
      act: (cubit) => cubit.start(),
      expect: () => [
        _loaded().having((s) => s.hasOtherCurrencies, 'other', true),
      ],
    );

    blocTest<EntriesCubit, EntriesState>(
      'outside the cycle are not noted',
      build: () => _cubit(InMemoryEntryRepository([lunch, oldYen])),
      act: (cubit) => cubit.start(),
      expect: () => [
        _loaded().having((s) => s.hasOtherCurrencies, 'other', false),
      ],
    );
  });

  late InMemorySettingsRepository settings;

  blocTest<EntriesCubit, EntriesState>(
    'follows a new default currency and cycle start day at once',
    setUp: () => settings = InMemorySettingsRepository(),
    build: () => _cubit(
      InMemoryEntryRepository([salary, lunch, lastMonth]),
      settingsRepository: settings,
    ),
    act: (cubit) async {
      cubit.start();
      await pumpEventQueue();
      await settings.update((s) => s.copyWith(cycleStartDay: 25));
      await settings.update((s) => s.copyWith(currency: Currency.usd));
    },
    skip: 1,
    expect: () => [
      _loaded()
          .having((s) => s.cycle, 'cycle', Cycle(2026, 9, startDay: 25))
          .having(
            (s) => s.balance,
            'balance',
            // 30 Sep is in the 25 Sep – 24 Oct cycle now.
            const CurrencyTotals(
              income: Money(3000000),
              expense: Money(105950),
            ),
          ),
      _loaded()
          .having((s) => s.currency, 'currency', Currency.usd)
          .having((s) => s.hasOtherCurrencies, 'other currencies', true),
    ],
  );

  blocTest<EntriesCubit, EntriesState>(
    'a new day moves "today" and the cycle when the app comes back',
    build: () {
      var today = LocalDate(2026, 10, 31);
      return _cubit(
        InMemoryEntryRepository([lunch]),
        today: () {
          final day = today;
          today = LocalDate(2026, 11, 1);
          return day;
        },
      );
    },
    act: (cubit) async {
      cubit.start();
      await pumpEventQueue();
      cubit.refreshToday();
    },
    expect: () => [
      _loaded().having((s) => s.today, 'today', LocalDate(2026, 10, 31)),
      _loaded()
          .having((s) => s.today, 'today', LocalDate(2026, 11, 1))
          .having((s) => s.cycle, 'cycle', Cycle(2026, 11, startDay: 1))
          .having(
            (s) => s.balance,
            'balance',
            const CurrencyTotals(income: Money(0), expense: Money(0)),
          ),
    ],
  );

  group('read errors (#60 Q3)', () {
    late ControlledEntryRepository entries;

    blocTest<EntriesCubit, EntriesState>(
      'a first read that fails says so, and try again reads once more',
      setUp: () => entries = ControlledEntryRepository(),
      build: () => _cubit(entries),
      act: (cubit) async {
        cubit.start();
        entries.stream.addError(const StorageUnreadable());
        await pumpEventQueue();
        cubit.retry();
        entries.stream.add([lunch]);
        await pumpEventQueue();
      },
      expect: () => [
        const EntriesUnreadable(),
        _loaded().having((s) => s.days, 'days', hasLength(1)),
      ],
    );

    blocTest<EntriesCubit, EntriesState>(
      'a later read error keeps the entries shown and counts each error',
      setUp: () => entries = ControlledEntryRepository(),
      build: () => _cubit(entries),
      act: (cubit) async {
        cubit.start();
        entries.stream.add([lunch]);
        await pumpEventQueue();
        entries.stream.addError(const StorageUnreadable());
        await pumpEventQueue();
        cubit.retry();
        entries.stream.addError(const StorageUnavailable());
        await pumpEventQueue();
      },
      expect: () => [
        _loaded().having((s) => s.failedReads, 'failed reads', 0),
        _loaded()
            .having((s) => s.failedReads, 'failed reads', 1)
            .having((s) => s.days, 'days', hasLength(1)),
        _loaded().having((s) => s.failedReads, 'failed reads', 2),
      ],
    );

    blocTest<EntriesCubit, EntriesState>(
      'settings that cannot be read fall back to the defaults',
      build: () => _cubit(
        InMemoryEntryRepository([lunch]),
        settingsRepository: _BrokenSettings(),
      ),
      act: (cubit) => cubit.start(),
      expect: () => [
        _loaded()
            .having((s) => s.currency, 'currency', Currency.thb)
            .having((s) => s.cycle, 'cycle', Cycle(2026, 10, startDay: 1)),
      ],
    );
  });
}

/// Settings whose stream only fails.
class _BrokenSettings extends InMemorySettingsRepository {
  @override
  Stream<AppSettings> watch() => Stream.error(const StorageUnreadable());

  @override
  Future<Either<Failure, AppSettings>> get() async =>
      const Left(StorageUnreadable());
}
