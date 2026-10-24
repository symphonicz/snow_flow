import 'package:get_it/get_it.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/add_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/delete_entry.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/get_default_currency.dart';
import 'package:snow_flow/features/entry_form/domain/usecases/update_entry.dart';
import 'package:snow_flow/features/entry_form/presentation/entry_form_cubit.dart';
import 'package:snow_flow/shared/domain/entry.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

void registerEntryForm(GetIt getIt) {
  getIt
    ..registerLazySingleton(() => AddEntry(getIt()))
    ..registerLazySingleton(() => UpdateEntry(getIt()))
    ..registerLazySingleton(() => DeleteEntry(getIt()))
    ..registerLazySingleton(() => GetDefaultCurrency(getIt(), getIt()))
    // param1 is the entry to edit; null for a new one.
    ..registerFactoryParam<EntryFormCubit, Entry?, void>(
      (entry, _) => EntryFormCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
        entry: entry,
        today: () => LocalDate.fromDateTime(DateTime.now()),
        now: () => DateTime.now().millisecondsSinceEpoch,
      ),
    );
}
