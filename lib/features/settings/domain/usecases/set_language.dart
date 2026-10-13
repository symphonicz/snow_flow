import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Once picked, the app stops following the device language (#54).
class SetLanguage {
  const SetLanguage(this._settings);

  final SettingsRepository _settings;

  Future<Either<Failure, Unit>> call(AppLanguage lang) =>
      _settings.update((settings) => settings.copyWith(lang: lang));
}
