import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/entries/domain/day_groups.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

Entry _entry(
  String id,
  LocalDate date, {
  int created = 0,
  EntryType type = EntryType.expense,
  int minorUnits = 100,
  Currency currency = Currency.thb,
}) => Entry(
  id: id,
  type: type,
  amount: Money(minorUnits),
  currency: currency,
  category: type == EntryType.income ? Categories.salary : Categories.food,
  date: date,
  created: created,
);

List<String> _ids(DayGroup group) => [for (final e in group.entries) e.id];

void main() {
  final oct1 = LocalDate(2026, 10, 1);
  final oct2 = LocalDate(2026, 10, 2);
  final oct3 = LocalDate(2026, 10, 3);

  test('groups by day, newest day first', () {
    final groups = groupByDay([
      _entry('a', oct2),
      _entry('b', oct3),
      _entry('c', oct1),
      _entry('d', oct3),
    ], defaultCurrency: Currency.thb);

    expect([for (final group in groups) group.date], [oct3, oct2, oct1]);
    expect(groups.first.entries.length, 2);
  });

  test('within a day, the newest saved comes first (#58)', () {
    final groups = groupByDay([
      _entry('morning', oct3, created: 100),
      _entry('night', oct3, created: 300),
      _entry('noon', oct3, created: 200),
    ], defaultCurrency: Currency.thb);

    expect(_ids(groups.single), ['night', 'noon', 'morning']);
  });

  test('the same created time is ordered by id, so the order is stable', () {
    final groups = groupByDay([
      _entry('b', oct3, created: 100),
      _entry('c', oct3, created: 100),
      _entry('a', oct3, created: 100),
    ], defaultCurrency: Currency.thb);

    expect(_ids(groups.single), ['a', 'b', 'c']);
  });

  group('net', () {
    test('is income minus expense of the day per currency', () {
      final groups = groupByDay([
        _entry('pay', oct3, type: EntryType.income, minorUnits: 50000),
        _entry('lunch', oct3, minorUnits: 6050),
        _entry('sushi', oct3, minorUnits: 120000, currency: Currency.jpy),
      ], defaultCurrency: Currency.thb);

      expect(groups.single.net, {
        Currency.thb: const Money(43950),
        Currency.jpy: const Money(-120000),
      });
    });

    test('lists the default currency first, then brief §4.5 (#58)', () {
      final groups = groupByDay([
        _entry('a', oct3, currency: Currency.aud),
        _entry('b', oct3),
        _entry('c', oct3, currency: Currency.jpy),
      ], defaultCurrency: Currency.jpy);

      expect(groups.single.net.keys, [
        Currency.jpy,
        Currency.thb,
        Currency.aud,
      ]);
    });

    test('keeps a currency whose day nets to zero', () {
      final groups = groupByDay([
        _entry('in', oct3, type: EntryType.income),
        _entry('out', oct3),
      ], defaultCurrency: Currency.thb);

      expect(groups.single.net, {Currency.thb: const Money(0)});
    });
  });

  test('no entry has no group', () {
    expect(groupByDay([], defaultCurrency: Currency.thb), isEmpty);
  });

  group('relativeTo picks the header word (#52)', () {
    DayGroup groupOn(LocalDate date) =>
        groupByDay([_entry('a', date)], defaultCurrency: Currency.thb).single;

    test('today and yesterday', () {
      expect(groupOn(oct3).relativeTo(oct3), RelativeDay.today);
      expect(groupOn(oct2).relativeTo(oct3), RelativeDay.yesterday);
      expect(groupOn(oct1).relativeTo(oct3), RelativeDay.other);
    });

    test('yesterday across a month and a year', () {
      expect(
        groupOn(LocalDate(2026, 9, 30)).relativeTo(oct1),
        RelativeDay.yesterday,
      );
      expect(
        groupOn(LocalDate(2025, 12, 31)).relativeTo(LocalDate(2026, 1, 1)),
        RelativeDay.yesterday,
      );
      expect(
        groupOn(LocalDate(2024, 2, 29)).relativeTo(LocalDate(2024, 3, 1)),
        RelativeDay.yesterday,
      );
    });
  });
}
