import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// Income and expense of one currency over a span of days: a cycle for the
/// balance card (brief §4.4), a day or a cycle for the summary (§4.3).
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
