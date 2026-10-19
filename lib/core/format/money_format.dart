import 'package:intl/intl.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// The real minus sign (U+2212) of brief §8, not a hyphen.
const _minusSign = '−';

/// An amount split for display, so the balance card can draw the symbol
/// smaller (brief §6). `'$parts'` reads the same as [formatMoney].
class MoneyParts {
  const MoneyParts({
    required this.sign,
    required this.symbol,
    required this.number,
  });

  /// `−`, `+` or empty.
  final String sign;

  /// The short symbol of intl, e.g. `฿` or `NT$` (#52).
  final String symbol;

  /// Grouped digits, e.g. `1,200.00`.
  final String number;

  @override
  String toString() => '$sign$symbol$number';
}

/// Splits [money] in [currency]: symbol before the number, `,` between
/// thousands and `.` before the decimals in both languages. Two-decimal
/// currencies always show both decimals; JPY, KRW, VND and LAK round half up
/// to a whole number (#12). A negative amount starts with `−`; [signed] adds
/// `+` to a positive one (#52).
MoneyParts moneyParts(Money money, Currency currency, {bool signed = false}) {
  final minorUnits = money.minorUnits;
  final sign = minorUnits < 0
      ? _minusSign
      : signed && minorUnits > 0
      ? '+'
      : '';
  return MoneyParts(
    sign: sign,
    symbol: _symbols[currency]!,
    number: _number(minorUnits.abs(), currency.fractionDigits),
  );
}

/// [moneyParts] as one string, e.g. `฿1,200.00`, `¥500` or `−฿60.00`.
String formatMoney(Money money, Currency currency, {bool signed = false}) =>
    '${moneyParts(money, currency, signed: signed)}';

final _symbols = {
  for (final currency in Currency.values)
    currency: NumberFormat.simpleCurrency(
      locale: 'en',
      name: currency.code,
    ).currencySymbol,
};

/// Works on the ×100 integer, so no double ever rounds a digit away.
String _number(int minorUnits, int fractionDigits) {
  if (fractionDigits == 0) return _group((minorUnits + 50) ~/ 100);
  final cents = '${minorUnits % 100}'.padLeft(2, '0');
  return '${_group(minorUnits ~/ 100)}.$cents';
}

String _group(int whole) => '$whole'.replaceAllMapped(
  RegExp(r'\d(?=(\d{3})+$)'),
  (match) => '${match[0]},',
);
