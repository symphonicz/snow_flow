import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// The settings once, e.g. to check at startup that they can be read.
class GetSettings {
  const GetSettings(this._settings);

  final SettingsRepository _settings;

  Future<Either<Failure, AppSettings>> call() => _settings.get();
}
