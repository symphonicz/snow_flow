part of 'entries_cubit.dart';

sealed class EntriesState extends Equatable {
  const EntriesState();

  @override
  List<Object> get props => const [];
}

/// Before the first read; the page shows nothing, since reading the device
/// is quick (#60).
final class EntriesLoading extends EntriesState {
  const EntriesLoading();
}

/// The first read failed, so there is nothing to show yet (#60 Q3).
final class EntriesUnreadable extends EntriesState {
  const EntriesUnreadable();
}

final class EntriesLoaded extends EntriesState {
  const EntriesLoaded({
    required this.today,
    required this.cycle,
    required this.currency,
    required this.balance,
    required this.hasOtherCurrencies,
    required this.days,
    this.failedReads = 0,
  });

  /// Picks "วันนี้" / "เมื่อวาน" for the day headers.
  final LocalDate today;

  /// The cycle [today] falls in; the balance card's.
  final Cycle cycle;

  /// The default currency of the settings.
  final Currency currency;

  /// [cycle]'s totals in [currency]; zero when it has no entry in it.
  final CurrencyTotals balance;

  /// Whether [cycle] has entries in another currency too (#12).
  final bool hasOtherCurrencies;

  /// Every entry by day, the newest first.
  final List<DayGroup> days;

  /// How many reads failed since the entries were shown; each one is a
  /// toast, while the entries already shown stay (#60 Q3).
  final int failedReads;

  EntriesLoaded _withFailedRead() => EntriesLoaded(
    today: today,
    cycle: cycle,
    currency: currency,
    balance: balance,
    hasOtherCurrencies: hasOtherCurrencies,
    days: days,
    failedReads: failedReads + 1,
  );

  @override
  List<Object> get props => [
    today,
    cycle,
    currency,
    balance,
    hasOtherCurrencies,
    days,
    failedReads,
  ];
}
