import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_order.dart';

void main() {
  test('the default currency comes first, then the order of brief §4.5', () {
    expect(
      orderCurrencies({
        Currency.aud,
        Currency.thb,
        Currency.jpy,
      }, defaultCurrency: Currency.jpy),
      [Currency.jpy, Currency.thb, Currency.aud],
    );
  });

  test('a default currency with no entry is not listed (#58)', () {
    expect(
      orderCurrencies({
        Currency.usd,
        Currency.thb,
      }, defaultCurrency: Currency.jpy),
      [Currency.thb, Currency.usd],
    );
  });

  test('no entry lists no currency', () {
    expect(orderCurrencies({}, defaultCurrency: Currency.thb), isEmpty);
  });
}
