import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// The totals of one cycle per currency, never converted between currencies
/// and never carried over from another cycle (brief §4.3, §4.4). The card
/// shows the default currency; any other in [currencies] means the cycle
/// has entries in another currency too (#12).
class CycleBalance extends Equatable {
  const CycleBalance._(this._totals);

  factory CycleBalance.of(Cycle cycle, Iterable<Entry> entries) {
    const zero = Money(0);
    final income = <Currency, Money>{};
    final expense = <Currency, Money>{};
    for (final entry in entries) {
      if (!cycle.contains(entry.date)) continue;
      final sums = entry.type == EntryType.income ? income : expense;
      sums[entry.currency] = (sums[entry.currency] ?? zero) + entry.amount;
    }
    return CycleBalance._({
      for (final currency in {...income.keys, ...expense.keys})
        currency: CurrencyTotals(
          income: income[currency] ?? zero,
          expense: expense[currency] ?? zero,
        ),
    });
  }

  final Map<Currency, CurrencyTotals> _totals;

  /// The currencies with at least one entry in the cycle.
  Set<Currency> get currencies => _totals.keys.toSet();

  /// Null when [currency] has no entry in the cycle.
  CurrencyTotals? operator [](Currency currency) => _totals[currency];

  @override
  List<Object> get props => [_totals];
}
