import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Stores the one [AppSettings]. Before anything is saved it reads as the
/// defaults.
abstract interface class SettingsRepository {
  Future<Either<Failure, AppSettings>> get();

  /// Emits the settings now, then again after each change. A broken box is
  /// sent as a [StorageUnreadable] error and the stream keeps going.
  Stream<AppSettings> watch();

  /// Reads, applies [change] and saves in one step, so two quick changes
  /// cannot overwrite each other.
  Future<Either<Failure, Unit>> update(
    AppSettings Function(AppSettings) change,
  );
}
