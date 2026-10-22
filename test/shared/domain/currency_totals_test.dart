import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/money.dart';

int? _percent(int income, int expense) =>
    CurrencyTotals(income: Money(income), expense: Money(expense)).spentPercent;

void main() {
  group('spentPercent', () {
    test('is expense over income, rounded half up', () {
      expect(_percent(100000, 25000), 25);
      expect(_percent(100000, 12550), 13);
      expect(_percent(100000, 12549), 13);
      expect(_percent(100000, 12449), 12);
    });

    test('goes past 100 when spending more than the income (#60 Q2)', () {
      expect(_percent(100000, 150000), 150);
    });

    test('shows 1 for any spending below 1%, never 0 (#60 Q2)', () {
      expect(_percent(100000, 300), 1);
      expect(_percent(100000000, 1), 1);
    });

    test('never says 100 before the income is all spent (#60 Q2)', () {
      expect(_percent(100000, 99600), 99);
      expect(_percent(100000, 99999), 99);
      expect(_percent(100000, 100000), 100);
    });

    test('is 0 with nothing spent', () {
      expect(_percent(100000, 0), 0);
    });

    test('is null with no income', () {
      expect(_percent(0, 6050), isNull);
    });
  });
}
