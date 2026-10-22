import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/summary/domain/summary.dart';
import 'package:snow_flow/features/summary/domain/summary_range.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

var _ids = 0;

Entry _expense(
  EntryCategory category,
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
}) => Entry(
  id: '${_ids++}',
  type: EntryType.expense,
  amount: Money(minorUnits),
  currency: currency,
  category: category,
  date: date,
  created: 0,
);

Entry _income(int minorUnits, LocalDate date) => Entry(
  id: '${_ids++}',
  type: EntryType.income,
  amount: Money(minorUnits),
  currency: Currency.thb,
  category: Categories.salary,
  date: date,
  created: 0,
);

void main() {
  final daily = DailyRange(Cycle(2026, 9, startDay: 25)); // 25 Sep – 24 Oct
  final sep25 = LocalDate(2026, 9, 25);
  final oct3 = LocalDate(2026, 10, 3);

  group('daily', () {
    final summary = Summary.of(daily, Currency.thb, [
      _income(3000000, sep25),
      _expense(Categories.food, 6050, sep25),
      _expense(Categories.food, 4000, oct3),
      _expense(Categories.bills, 120000, oct3),
      _expense(Categories.fun, 99900, oct3, currency: Currency.jpy),
      _expense(Categories.fun, 50000, LocalDate(2026, 10, 25)),
    ]);

    test('totals of the whole range, in the currency only', () {
      expect(
        summary.totals,
        const CurrencyTotals(income: Money(3000000), expense: Money(130050)),
      );
      expect(summary.totals.balance, const Money(2869950));
    });

    test('one period per day, each with its own totals', () {
      expect(summary.periods.length, 30);
      expect(summary.periods.first.period, Period.day(sep25));
      expect(
        summary.periods.first.totals,
        const CurrencyTotals(income: Money(3000000), expense: Money(6050)),
      );
      expect(summary.periods[8].period, Period.day(oct3));
      expect(summary.periods[8].totals.expense, const Money(124000));
      expect(
        summary.periods[1].totals,
        const CurrencyTotals(income: Money(0), expense: Money(0)),
      );
    });

    test('expense per category per period, for the stacked bars', () {
      expect(summary.periods[8].expenseByCategory, {
        Categories.food: const Money(4000),
        Categories.bills: const Money(120000),
      });
      expect(summary.periods[1].expenseByCategory, isEmpty);
    });

    test('ranks the categories of the whole range and of one period', () {
      expect(
        [for (final share in summary.ranking) share.category],
        [Categories.bills, Categories.food],
      );
      expect(summary.ranking.last.amount, const Money(10050));
      expect(summary.periods.first.ranking.single.percent, 100);
    });
  });

  group('categoryOrder (#19)', () {
    test('follows the whole range, the most spent first', () {
      final summary = Summary.of(daily, Currency.thb, [
        _expense(Categories.food, 100, sep25),
        _expense(Categories.bills, 300, oct3),
        _expense(Categories.food, 100, oct3),
        _expense(Categories.health, 200, oct3),
      ]);

      expect(summary.categoryOrder, [
        Categories.bills,
        Categories.food,
        Categories.health,
      ]);
    });

    test('equal totals keep the order of brief §5', () {
      final summary = Summary.of(daily, Currency.thb, [
        _expense(Categories.health, 100, oct3),
        _expense(Categories.transport, 100, oct3),
      ]);

      expect(summary.categoryOrder, [Categories.transport, Categories.health]);
    });

    test('is empty when nothing is spent, though the periods stay', () {
      final summary = Summary.of(daily, Currency.thb, [_income(100000, oct3)]);

      expect(summary.categoryOrder, isEmpty);
      expect(summary.ranking, isEmpty);
      expect(summary.periods.length, 30);
    });
  });

  group('monthly', () {
    test('one period per cycle; a cycle across new year counts in it', () {
      final summary =
          Summary.of(MonthlyRange(2026, startDay: 25), Currency.thb, [
            _expense(Categories.food, 100, LocalDate(2026, 1, 24)),
            _expense(Categories.food, 200, LocalDate(2026, 1, 25)),
            _expense(Categories.food, 300, LocalDate(2027, 1, 24)),
            _expense(Categories.food, 400, LocalDate(2027, 1, 25)),
          ]);

      expect(summary.periods.length, 12);
      expect(summary.periods.first.totals.expense, const Money(200));
      expect(summary.periods.last.totals.expense, const Money(300));
      expect(summary.totals.expense, const Money(500));
    });
  });

  group('currenciesOf (brief §4.3)', () {
    test('lists every currency with an entry, the default first (#58)', () {
      expect(
        currenciesOf([
          _expense(Categories.food, 100, oct3, currency: Currency.usd),
          _expense(Categories.food, 100, oct3, currency: Currency.jpy),
          _expense(Categories.food, 100, LocalDate(2020, 1, 1)),
        ], defaultCurrency: Currency.jpy),
        [Currency.jpy, Currency.thb, Currency.usd],
      );
    });
  });
}
