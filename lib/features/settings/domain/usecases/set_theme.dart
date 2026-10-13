import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Light, dark or follow the device.
class SetTheme {
  const SetTheme(this._settings);

  final SettingsRepository _settings;

  Future<Either<Failure, Unit>> call(ThemePreference theme) =>
      _settings.update((settings) => settings.copyWith(theme: theme));
}
