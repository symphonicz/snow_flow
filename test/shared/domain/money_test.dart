import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/shared/domain/money.dart';

void main() {
  group('Money.parse', () {
    Object? parse(String text) =>
        Money.parse(text).fold((problem) => problem, (money) => money);

    test('reads typed amounts as minor units ×100', () {
      expect(parse('60.50'), const Money(6050));
      expect(parse('60.5'), const Money(6050));
      expect(parse('500'), const Money(50000));
      expect(parse(' 0.01 '), const Money(1));
      expect(parse('60.'), const Money(6000));
      expect(parse('.5'), const Money(50));
      expect(parse('999999999.99'), const Money(99999999999));
    });

    test('does not drift like doubles', () {
      expect(parse('0.29'), const Money(29));
      expect(parse('1.15'), const Money(115));
    });

    test('rejects text that is not a number', () {
      for (final text in ['', ' ', '.', 'abc', '1,000', '1.2.3', '1e3']) {
        expect(parse(text), AmountProblem.invalid, reason: text);
      }
    });

    test('rejects more than 2 decimal places', () {
      expect(parse('60.555'), AmountProblem.tooManyDecimals);
      expect(parse('0.001'), AmountProblem.tooManyDecimals);
    });

    test('rejects zero and negative amounts', () {
      for (final text in ['0', '0.00', '-0', '-5']) {
        expect(parse(text), AmountProblem.notPositive, reason: text);
      }
    });

    test('rejects amounts above 999,999,999.99', () {
      expect(parse('1000000000'), AmountProblem.tooLarge);
      expect(parse('99999999999999999999999'), AmountProblem.tooLarge);
    });

    test('leading zeros do not count toward the limit', () {
      expect(parse('000000000012.30'), const Money(1230));
    });
  });

  group('Money.problem', () {
    test('is null for amounts inside the limits', () {
      expect(const Money(1).problem, isNull);
      expect(const Money(Money.maxMinorUnits).problem, isNull);
    });

    test('names the broken rule', () {
      expect(const Money(0).problem, AmountProblem.notPositive);
      expect(const Money(-1).problem, AmountProblem.notPositive);
      expect(
        const Money(Money.maxMinorUnits + 1).problem,
        AmountProblem.tooLarge,
      );
    });
  });

  group('Money.toDecimal (backup file)', () {
    test('writes minor units back as a decimal', () {
      expect(const Money(6050).toDecimal(), 60.5);
      expect(const Money(1).toDecimal(), 0.01);
      expect(const Money(99999999999).toDecimal(), 999999999.99);
    });

    test('writes whole amounts as integers', () {
      expect(const Money(50000).toDecimal(), 500);
      expect(const Money(50000).toDecimal(), isA<int>());
    });
  });

  test('adds and subtracts exactly', () {
    expect(const Money(10) + const Money(20), const Money(30));
    expect(const Money(10) - const Money(30), const Money(-20));
  });
}
