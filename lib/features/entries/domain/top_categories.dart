import 'package:snow_flow/shared/domain/category_ranking.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';

/// The web card "ใช้มากที่สุดเดือนนี้" (brief §4.2): up to four categories
/// spent most in [cycle], in [currency] only. The page passes the current
/// cycle and the default currency, like the balance card (#58).
List<CategoryShare> topCategories(
  Cycle cycle,
  Currency currency,
  Iterable<Entry> entries,
) => rankCategories(
  expenseByCategory(
    entries.where(
      (entry) => entry.currency == currency && cycle.contains(entry.date),
    ),
  ),
).take(4).toList();
