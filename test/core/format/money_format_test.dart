import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/format/money_format.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/money.dart';

void main() {
  group('formatMoney', () {
    test('two-decimal currencies always show .00', () {
      expect(formatMoney(const Money(6000), Currency.thb), '฿60.00');
      expect(formatMoney(const Money(6050), Currency.thb), '฿60.50');
      expect(formatMoney(const Money(5), Currency.usd), r'$0.05');
    });

    test('groups thousands with commas', () {
      expect(formatMoney(const Money(120000), Currency.thb), '฿1,200.00');
      expect(
        formatMoney(const Money(99999999999), Currency.eur),
        '€999,999,999.99',
      );
    });

    test('a total far above one entry still shows every digit (#37)', () {
      expect(
        formatMoney(const Money(9999999999999), Currency.thb),
        '฿99,999,999,999.99',
      );
    });

    test('JPY, KRW, VND and LAK show whole numbers (#12)', () {
      expect(formatMoney(const Money(50000), Currency.jpy), '¥500');
      expect(formatMoney(const Money(2500000), Currency.vnd), '₫25,000');
      expect(formatMoney(const Money(100000), Currency.krw), '₩1,000');
      expect(formatMoney(const Money(1000000), Currency.lak), '₭10,000');
    });

    test('an imported fraction rounds half up for display (#12)', () {
      expect(formatMoney(const Money(50050), Currency.jpy), '¥501');
      expect(formatMoney(const Money(50049), Currency.jpy), '¥500');
    });

    test('uses the short symbols of intl for all 14 currencies', () {
      final symbols = {
        for (final currency in Currency.values)
          currency: moneyParts(const Money(100), currency).symbol,
      };
      expect(symbols, {
        Currency.thb: '฿',
        Currency.usd: r'$',
        Currency.eur: '€',
        Currency.jpy: '¥',
        Currency.cny: '¥',
        Currency.krw: '₩',
        Currency.gbp: '£',
        Currency.sgd: r'$',
        Currency.myr: 'RM',
        Currency.lak: '₭',
        Currency.vnd: '₫',
        Currency.hkd: r'$',
        Currency.twd: r'NT$',
        Currency.aud: r'$',
      });
    });

    test('a negative amount starts with a real minus sign', () {
      expect(formatMoney(const Money(-6000), Currency.thb), '−฿60.00');
      expect(formatMoney(const Money(-50050), Currency.jpy), '−¥501');
    });

    test('signed adds + to a positive amount, never to zero', () {
      expect(
        formatMoney(const Money(120000), Currency.thb, signed: true),
        '+฿1,200.00',
      );
      expect(
        formatMoney(const Money(-6000), Currency.thb, signed: true),
        '−฿60.00',
      );
      expect(formatMoney(const Money(0), Currency.thb, signed: true), '฿0.00');
    });
  });

  group('moneyParts', () {
    test('splits sign, symbol and number for a smaller symbol', () {
      final parts = moneyParts(const Money(-120050), Currency.thb);

      expect(parts.sign, '−');
      expect(parts.symbol, '฿');
      expect(parts.number, '1,200.50');
    });

    test('joined parts read the same as formatMoney', () {
      const money = Money(123456);
      expect(
        '${moneyParts(money, Currency.usd, signed: true)}',
        formatMoney(money, Currency.usd, signed: true),
      );
    });
  });
}
