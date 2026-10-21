import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// Income and expense of one currency in one cycle (brief §4.4).
class CurrencyTotals extends Equatable {
  const CurrencyTotals({required this.income, required this.expense});

  final Money income;
  final Money expense;

  /// Income minus expense; below zero when spending more than the income.
  Money get balance => income - expense;

  /// Expense over income for the balance card's bar, at most 1.0. Null with
  /// no income, when the card shows "ยังไม่มีรายรับเดือนนี้" instead.
  double? get spentRatio {
    if (income.minorUnits <= 0) return null;
    final ratio = expense.minorUnits / income.minorUnits;
    return ratio > 1 ? 1.0 : ratio;
  }

  @override
  List<Object> get props => [income, expense];
}

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
