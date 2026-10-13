import 'package:get_it/get_it.dart';
import 'package:snow_flow/features/settings/domain/usecases/clear_all_entries.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_currency.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_cycle_start_day.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_language.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_reminder.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_theme.dart';

void registerSettings(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => ClearAllEntries(getIt()))
    ..registerLazySingleton(() => SetTheme(getIt()))
    ..registerLazySingleton(() => SetLanguage(getIt()))
    ..registerLazySingleton(() => SetCurrency(getIt()))
    ..registerLazySingleton(() => SetReminder(getIt()))
    ..registerLazySingleton(() => SetCycleStartDay(getIt()));
}
