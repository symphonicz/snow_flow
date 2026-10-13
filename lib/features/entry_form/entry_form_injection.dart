import 'package:get_it/get_it.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/add_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/delete_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/update_entry.dart';

void registerEntryForm(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => AddEntry(getIt()))
    ..registerLazySingleton(() => UpdateEntry(getIt()))
    ..registerLazySingleton(() => DeleteEntry(getIt()))
    ..registerLazySingleton(() => GetDefaultCurrency(getIt(), getIt()));
}
