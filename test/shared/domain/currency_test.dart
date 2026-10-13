import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/currency.dart';

void main() {
  test('lists the 14 currencies in the order of brief §4.5', () {
    expect(Currency.values.map((c) => c.code), [
      'THB', 'USD', 'EUR', 'JPY', 'CNY', 'KRW', 'GBP', //
      'SGD', 'MYR', 'LAK', 'VND', 'HKD', 'TWD', 'AUD',
    ]);
  });

  test('tryParse ignores letter case', () {
    expect(Currency.tryParse('THB'), Currency.thb);
    expect(Currency.tryParse('jpy'), Currency.jpy);
    expect(Currency.tryParse('Usd'), Currency.usd);
  });

  test('tryParse returns null for unsupported codes', () {
    for (final code in ['', 'XXX', 'CHF', ' THB', 'TH']) {
      expect(Currency.tryParse(code), isNull, reason: code);
    }
  });

  test('JPY, KRW, VND and LAK show no decimals', () {
    expect(Currency.values.where((c) => c.fractionDigits == 0), [
      Currency.jpy,
      Currency.krw,
      Currency.lak,
      Currency.vnd,
    ]);
    expect(Currency.thb.fractionDigits, 2);
  });
}
