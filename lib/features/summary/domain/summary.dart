import 'package:equatable/equatable.dart';
import 'package:snow_flow/features/summary/domain/summary_range.dart';
import 'package:snow_flow/shared/domain/category_ranking.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_order.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// The summary picker's currencies (brief §4.3): every currency with an
/// entry at any date, so the picker stays the same while moving between
/// ranges, the default first then brief §4.5 (#58).
List<Currency> currenciesOf(
  Iterable<Entry> entries, {
  required Currency defaultCurrency,
}) => orderCurrencies({
  for (final entry in entries) entry.currency,
}, defaultCurrency: defaultCurrency);

/// The totals and spending of one bar in the chart.
class PeriodSummary extends Equatable {
  const PeriodSummary({
    required this.period,
    required this.totals,
    required this.expenseByCategory,
  });

  final Period period;
  final CurrencyTotals totals;

  /// The layers of the stacked bar; a category with no expense is absent.
  final Map<EntryCategory, Money> expenseByCategory;

  /// "เงินหมดไปกับอะไร" when this bar is selected.
  List<CategoryShare> get ranking => rankCategories(expenseByCategory);

  @override
  List<Object> get props => [period, totals, expenseByCategory];
}

/// The summary page of one [range] in one [currency] (brief §4.3). Amounts
/// are never converted, so entries in other currencies are left out.
class Summary extends Equatable {
  const Summary._({
    required this.range,
    required this.currency,
    required this.totals,
    required this.expenseByCategory,
    required this.periods,
  });

  factory Summary.of(
    SummaryRange range,
    Currency currency,
    Iterable<Entry> entries,
  ) {
    final inRange = [
      for (final entry in entries)
        if (entry.currency == currency && range.contains(entry.date)) entry,
    ];
    final whole = _periodSummary(Period(range.start, range.end), inRange);
    return Summary._(
      range: range,
      currency: currency,
      totals: whole.totals,
      expenseByCategory: whole.expenseByCategory,
      periods: [
        for (final period in range.periods)
          _periodSummary(period, [
            for (final entry in inRange)
              if (period.contains(entry.date)) entry,
          ]),
      ],
    );
  }

  final SummaryRange range;
  final Currency currency;

  /// The three total cards of the whole range: income, expense, balance.
  final CurrencyTotals totals;

  final Map<EntryCategory, Money> expenseByCategory;

  /// One per bar, in date order, including those with no entry.
  final List<PeriodSummary> periods;

  /// "เงินหมดไปกับอะไร" of the whole range.
  List<CategoryShare> get ranking => rankCategories(expenseByCategory);

  /// The stacking order of every bar and of the legend, bottom first: the
  /// whole range's most spent category first (#19). It stays the same when
  /// a bar is selected. Empty when nothing is spent, so there is no legend.
  List<EntryCategory> get categoryOrder => [
    for (final entry in sortByAmount(expenseByCategory)) entry.key,
  ];

  @override
  List<Object> get props => [
    range,
    currency,
    totals,
    expenseByCategory,
    periods,
  ];
}

PeriodSummary _periodSummary(Period period, List<Entry> entries) =>
    PeriodSummary(
      period: period,
      totals: _totals(entries),
      expenseByCategory: expenseByCategory(entries),
    );

CurrencyTotals _totals(Iterable<Entry> entries) {
  var income = const Money(0);
  var expense = const Money(0);
  for (final entry in entries) {
    if (entry.type == EntryType.income) {
      income += entry.amount;
    } else {
      expense += entry.amount;
    }
  }
  return CurrencyTotals(income: income, expense: expense);
}
