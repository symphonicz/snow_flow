/// The 14 supported ISO 4217 currencies, in the order of brief §4.5.
enum Currency {
  thb('THB'),
  usd('USD'),
  eur('EUR'),
  jpy('JPY', fractionDigits: 0),
  cny('CNY'),
  krw('KRW', fractionDigits: 0),
  gbp('GBP'),
  sgd('SGD'),
  myr('MYR'),
  lak('LAK', fractionDigits: 0),
  vnd('VND', fractionDigits: 0),
  hkd('HKD'),
  twd('TWD'),
  aud('AUD');

  const Currency(this.code, {this.fractionDigits = 2});

  final String code;

  /// Decimals shown and typed. Storage is ×100 for every currency (ADR 0002).
  final int fractionDigits;

  static final _byCode = {
    for (final currency in values) currency.code: currency,
  };

  /// Reads a stored code exactly as [code] writes it; null otherwise.
  static Currency? byCode(String code) => _byCode[code];

  /// Reads a typed or imported code in any letter case (#17); null when it is
  /// not one of the 14.
  static Currency? tryParse(String code) => byCode(code.toUpperCase());
}
