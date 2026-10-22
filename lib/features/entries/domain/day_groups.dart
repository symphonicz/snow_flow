import 'package:equatable/equatable.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_order.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/entry_type.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';

/// Which word a day header uses (brief §4.2): "วันนี้", "เมื่อวาน", or the
/// day's name and date (#52).
enum RelativeDay { today, yesterday, other }

/// The entries of one day in the entries list (brief §4.2).
class DayGroup extends Equatable {
  const DayGroup({
    required this.date,
    required this.entries,
    required this.net,
  });

  final LocalDate date;

  /// The newest saved first (#58).
  final List<Entry> entries;

  /// Income minus expense of the day per currency, never converted, in
  /// display order: the default currency first, then brief §4.5 (#58). A
  /// currency netting to zero stays, since the day has entries in it.
  final Map<Currency, Money> net;

  RelativeDay relativeTo(LocalDate today) {
    if (date == today) return RelativeDay.today;
    return date.nextDay == today ? RelativeDay.yesterday : RelativeDay.other;
  }

  @override
  List<Object> get props => [date, entries, net];
}

/// [entries] grouped by day, the newest day first (brief §4.2). Within a day
/// the newest saved comes first, and the same `created` falls back to `id`
/// so the order never changes between rebuilds (#58).
List<DayGroup> groupByDay(
  Iterable<Entry> entries, {
  required Currency defaultCurrency,
}) {
  final byDate = <LocalDate, List<Entry>>{};
  for (final entry in entries) {
    (byDate[entry.date] ??= []).add(entry);
  }
  final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      _dayGroup(date, byDate[date]!, defaultCurrency: defaultCurrency),
  ];
}

DayGroup _dayGroup(
  LocalDate date,
  List<Entry> entries, {
  required Currency defaultCurrency,
}) {
  entries.sort((a, b) {
    final order = b.created.compareTo(a.created);
    return order != 0 ? order : a.id.compareTo(b.id);
  });
  final net = <Currency, Money>{};
  for (final entry in entries) {
    final signed = entry.type == EntryType.income
        ? entry.amount
        : const Money(0) - entry.amount;
    net[entry.currency] = (net[entry.currency] ?? const Money(0)) + signed;
  }
  return DayGroup(
    date: date,
    entries: entries,
    net: {
      for (final currency in orderCurrencies(
        net.keys.toSet(),
        defaultCurrency: defaultCurrency,
      ))
        currency: net[currency]!,
    },
  );
}
