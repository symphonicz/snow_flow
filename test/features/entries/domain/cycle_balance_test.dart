import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/entries/domain/cycle_balance.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

var _ids = 0;

Entry _entry(
  EntryType type,
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
}) => Entry(
  id: '${_ids++}',
  type: type,
  amount: Money(minorUnits),
  currency: currency,
  category: type == EntryType.income ? Categories.salary : Categories.food,
  date: date,
  created: 0,
);

Entry _income(
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
}) => _entry(EntryType.income, minorUnits, date, currency: currency);

Entry _expense(
  int minorUnits,
  LocalDate date, {
  Currency currency = Currency.thb,
}) => _entry(EntryType.expense, minorUnits, date, currency: currency);

void main() {
  final cycle = Cycle(2026, 9, startDay: 25); // 25 Sep – 24 Oct 2026

  test('balance is income minus expense of the cycle', () {
    final balance = CycleBalance.of(cycle, [
      _income(3000000, LocalDate(2026, 9, 25)),
      _expense(6050, LocalDate(2026, 10, 3)),
      _expense(120000, LocalDate(2026, 10, 24)),
    ]);

    final thb = balance[Currency.thb]!;
    expect(thb.income, const Money(3000000));
    expect(thb.expense, const Money(126050));
    expect(thb.balance, const Money(2873950));
  });

  test('entries outside the cycle never carry over (brief §4.4)', () {
    final balance = CycleBalance.of(cycle, [
      _income(500000, LocalDate(2026, 9, 24)),
      _expense(100000, LocalDate(2026, 10, 25)),
      _expense(6050, LocalDate(2026, 10, 1)),
    ]);

    final thb = balance[Currency.thb]!;
    expect(thb.income, const Money(0));
    expect(thb.expense, const Money(6050));
    expect(thb.balance, const Money(-6050));
  });

  test('each currency has its own totals, never converted', () {
    final balance = CycleBalance.of(cycle, [
      _income(3000000, LocalDate(2026, 10, 1), currency: Currency.jpy),
      _expense(50000, LocalDate(2026, 10, 2), currency: Currency.jpy),
      _expense(6050, LocalDate(2026, 10, 3)),
    ]);

    expect(balance.currencies, {Currency.jpy, Currency.thb});
    expect(balance[Currency.jpy]!.balance, const Money(2950000));
    expect(balance[Currency.thb]!.balance, const Money(-6050));
  });

  test('a currency with no entry in the cycle has no totals', () {
    final balance = CycleBalance.of(cycle, [
      _expense(6050, LocalDate(2026, 10, 3)),
    ]);

    expect(balance[Currency.usd], isNull);
    expect(CycleBalance.of(cycle, []).currencies, isEmpty);
  });

  group('spentRatio', () {
    test('is expense over income', () {
      final balance = CycleBalance.of(cycle, [
        _income(100000, LocalDate(2026, 10, 1)),
        _expense(25000, LocalDate(2026, 10, 2)),
      ]);

      expect(balance[Currency.thb]!.spentRatio, 0.25);
    });

    test('stops at 100% when spending more than the income', () {
      final balance = CycleBalance.of(cycle, [
        _income(100000, LocalDate(2026, 10, 1)),
        _expense(150000, LocalDate(2026, 10, 2)),
      ]);

      expect(balance[Currency.thb]!.spentRatio, 1.0);
    });

    test('is 0 with income but nothing spent', () {
      final balance = CycleBalance.of(cycle, [
        _income(100000, LocalDate(2026, 10, 1)),
      ]);

      expect(balance[Currency.thb]!.spentRatio, 0.0);
    });

    test('is null with no income, so the card says so (brief §4.4)', () {
      final balance = CycleBalance.of(cycle, [
        _expense(6050, LocalDate(2026, 10, 3)),
      ]);

      expect(balance[Currency.thb]!.spentRatio, isNull);
    });
  });
}
