import 'package:get_it/get_it.dart';
import 'package:snow_flow/features/entries/presentation/entries_cubit.dart';
import 'package:snow_flow/shared/domain/local_date.dart';

void registerEntries(GetIt getIt) {
  getIt.registerFactory(
    () => EntriesCubit(
      getIt(),
      getIt(),
      today: () => LocalDate.fromDateTime(DateTime.now()),
    ),
  );
}
