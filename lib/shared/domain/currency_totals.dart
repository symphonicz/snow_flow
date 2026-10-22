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

  /// Expense over income in whole percent for "ใช้ไปแล้ว X%", past 100 when
  /// spending more than the income (#60 Q2). Rounds half up, but any
  /// spending shows at least 1 and below the income never shows 100. Null
  /// with no income.
  int? get spentPercent {
    final income = this.income.minorUnits;
    final expense = this.expense.minorUnits;
    if (income <= 0) return null;
    // Integers only, so no double rounds the half away.
    final percent = (200 * expense + income) ~/ (2 * income);
    if (expense > 0 && percent == 0) return 1;
    if (expense < income && percent >= 100) return 99;
    return percent;
  }

  @override
  List<Object> get props => [income, expense];
}
