import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/features/entries/domain/cycle_balance.dart';
import 'package:snow_flow/features/entries/domain/day_groups.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/currency.dart';
import 'package:snow_flow/shared/domain/currency_totals.dart';
import 'package:snow_flow/shared/domain/cycle.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/local_date.dart';
import 'package:snow_flow/shared/domain/money.dart';
import 'package:snow_flow/shared/domain/usecases/watch_entries.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

part 'entries_state.dart';

/// The entries page (brief §4.2): the balance card of the current cycle in
/// the default currency, and every entry by day. Follows each change of the
/// entries and the settings at once.
class EntriesCubit extends Cubit<EntriesState> {
  EntriesCubit(
    this._watchEntries,
    this._watchSettings, {
    required LocalDate Function() today,
  }) : _today = today,
       super(const EntriesLoading());

  final WatchEntries _watchEntries;
  final WatchSettings _watchSettings;
  final LocalDate Function() _today;

  StreamSubscription<List<Entry>>? _entriesSubscription;
  StreamSubscription<AppSettings>? _settingsSubscription;
  List<Entry>? _entries;
  AppSettings? _settings;

  void start() {
    _settingsSubscription ??= _watchSettings().listen(
      (settings) {
        _settings = settings;
        _show();
      },
      // Like AppSettingsCubit: the defaults when the first read fails,
      // otherwise the settings already in use (#60 Q3).
      onError: (Object _) {
        if (_settings != null) return;
        _settings = const AppSettings();
        _show();
      },
    );
    if (_entriesSubscription == null) _watch();
  }

  /// Listens to the entries again after a read error (#60 Q3).
  void retry() {
    unawaited(_entriesSubscription?.cancel());
    _watch();
  }

  /// Picks today again, e.g. when the app comes back after midnight (#60).
  void refreshToday() => _show();

  void _watch() {
    _entriesSubscription = _watchEntries().listen(
      (entries) {
        _entries = entries;
        _show();
      },
      onError: (Object _) => emit(switch (state) {
        final EntriesLoaded shown => shown._withFailedRead(),
        _ => const EntriesUnreadable(),
      }),
    );
  }

  void _show() {
    final entries = _entries;
    final settings = _settings;
    if (entries == null || settings == null) return;
    final today = _today();
    final cycle = Cycle.containing(today, startDay: settings.cycleStartDay);
    final balance = CycleBalance.of(cycle, entries);
    emit(
      EntriesLoaded(
        today: today,
        cycle: cycle,
        currency: settings.currency,
        balance:
            balance[settings.currency] ??
            const CurrencyTotals(income: Money(0), expense: Money(0)),
        hasOtherCurrencies: balance.currencies.any(
          (currency) => currency != settings.currency,
        ),
        days: groupByDay(entries, defaultCurrency: settings.currency),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _entriesSubscription?.cancel();
    await _settingsSubscription?.cancel();
    return super.close();
  }
}
