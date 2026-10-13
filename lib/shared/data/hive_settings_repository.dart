import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/shared/data/hive_storage.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Keeps the settings as one [AppSettings.toMap] under [key].
class HiveSettingsRepository implements SettingsRepository {
  HiveSettingsRepository(this._box);

  /// Never rename it (ADR 0001).
  static const key = 'settings';

  final Box<dynamic> _box;

  AppSettings _read() {
    final value = _box.get(key);
    return value == null
        ? const AppSettings()
        : AppSettings.fromMap(requireMap(value));
  }

  @override
  Future<Either<Failure, AppSettings>> get() =>
      guardStorage(() => Right(_read()));

  @override
  Stream<AppSettings> watch() => watchBox(_box, _read);

  @override
  Future<Either<Failure, Unit>> update(
    AppSettings Function(AppSettings) change,
  ) => guardStorage(() async {
    // No await between reading and put: hive_ce updates memory before it
    // writes to disk, so a second update reads this one's result.
    await _box.put(key, change(_read()).toMap());
    return const Right(unit);
  });
}
