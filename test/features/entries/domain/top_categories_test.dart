import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/features/entries/domain/top_categories.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

var _ids = 0;

Entry _expense(
  EntryCategory category,
  int minorUnits, {
  LocalDate? date,
  Currency currency = Currency.thb,
}) => Entry(
  id: '${_ids++}',
  type: EntryType.expense,
  amount: Money(minorUnits),
  currency: currency,
  category: category,
  date: date ?? LocalDate(2026, 10, 3),
  created: 0,
);

void main() {
  final cycle = Cycle(2026, 9, startDay: 25); // 25 Sep – 24 Oct 2026

  test('the four most spent categories of the cycle', () {
    final top = topCategories(cycle, Currency.thb, [
      _expense(Categories.food, 500),
      _expense(Categories.transport, 400),
      _expense(Categories.shopping, 300),
      _expense(Categories.bills, 200),
      _expense(Categories.fun, 100),
      _expense(Categories.food, 100),
    ]);

    expect(
      [for (final share in top) share.category],
      [
        Categories.food,
        Categories.transport,
        Categories.shopping,
        Categories.bills,
      ],
    );
    expect(top.first.amount, const Money(600));
  });

  test('only expenses of the currency in the cycle count (#58)', () {
    final top = topCategories(cycle, Currency.thb, [
      _expense(Categories.food, 500),
      _expense(Categories.fun, 900, date: LocalDate(2026, 9, 24)),
      _expense(Categories.bills, 900, date: LocalDate(2026, 10, 25)),
      _expense(Categories.health, 900, currency: Currency.jpy),
      Entry(
        id: 'pay',
        type: EntryType.income,
        amount: const Money(900000),
        currency: Currency.thb,
        category: Categories.other,
        date: LocalDate(2026, 10, 1),
        created: 0,
      ),
    ]);

    expect([for (final share in top) share.category], [Categories.food]);
  });

  test('fewer categories show as many as there are', () {
    expect(topCategories(cycle, Currency.thb, []), isEmpty);
  });
}
