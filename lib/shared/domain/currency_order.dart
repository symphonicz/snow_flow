import 'package:snow_flow/shared/domain/currency.dart';

/// [currencies] in display order (#58): [defaultCurrency] first when it is
/// one of them, then the order of brief §4.5. Used by the summary's currency
/// picker and the day headers' net amounts.
List<Currency> orderCurrencies(
  Set<Currency> currencies, {
  required Currency defaultCurrency,
}) => [
  if (currencies.contains(defaultCurrency)) defaultCurrency,
  for (final currency in Currency.values)
    if (currency != defaultCurrency && currencies.contains(currency)) currency,
];
