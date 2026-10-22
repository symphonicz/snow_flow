import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// One category's part of the expense in "เงินหมดไปกับอะไร" (brief §4.3).
class CategoryShare extends Equatable {
  const CategoryShare({
    required this.category,
    required this.amount,
    required this.ratio,
    required this.percent,
  });

  final EntryCategory category;
  final Money amount;

  /// Exact part of the total, 0–1, for the bar's length.
  final double ratio;

  /// Whole percent for display.
  final int percent;

  @override
  List<Object> get props => [category, amount, ratio, percent];
}

/// The expense of [entries] per category; income is left out. The caller
/// picks the entries of one currency, since amounts are never converted.
Map<EntryCategory, Money> expenseByCategory(Iterable<Entry> entries) {
  final amounts = <EntryCategory, Money>{};
  for (final entry in entries) {
    if (entry.type != EntryType.expense) continue;
    amounts[entry.category] =
        (amounts[entry.category] ?? const Money(0)) + entry.amount;
  }
  return amounts;
}

/// [amounts] from the most spent to the least; equal amounts keep the order
/// of brief §5 (#19). Percents add up to exactly 100: each gets its whole
/// part and the largest remainders get one more, the higher rank first (#58).
List<CategoryShare> rankCategories(Map<EntryCategory, Money> amounts) {
  final ranked = sortByAmount(amounts);
  final total = ranked.fold<int>(
    0,
    (sum, entry) => sum + entry.value.minorUnits,
  );
  final percents = <int>[
    for (final entry in ranked) entry.value.minorUnits * 100 ~/ total,
  ];
  final byRemainder = [for (var i = 0; i < ranked.length; i++) i]
    ..sort((a, b) {
      int remainder(int i) => ranked[i].value.minorUnits * 100 % total;
      final order = remainder(b).compareTo(remainder(a));
      return order != 0 ? order : a.compareTo(b);
    });
  final missing = 100 - percents.fold<int>(0, (sum, percent) => sum + percent);
  for (final i in byRemainder.take(missing)) {
    percents[i]++;
  }
  return [
    for (var i = 0; i < ranked.length; i++)
      CategoryShare(
        category: ranked[i].key,
        amount: ranked[i].value,
        ratio: ranked[i].value.minorUnits / total,
        percent: percents[i],
      ),
  ];
}

/// [amounts] from the largest to the smallest; equal amounts keep the order
/// of brief §5. Also the color order of the chart (#19).
List<MapEntry<EntryCategory, Money>> sortByAmount(
  Map<EntryCategory, Money> amounts,
) => amounts.entries.toList()
  ..sort((a, b) {
    final order = b.value.minorUnits.compareTo(a.value.minorUnits);
    return order != 0
        ? order
        : Categories.all
              .indexOf(a.key)
              .compareTo(Categories.all.indexOf(b.key));
  });
