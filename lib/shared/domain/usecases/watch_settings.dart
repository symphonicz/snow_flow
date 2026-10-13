import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// The settings now and after each change. Failures come as stream errors
/// (#18 Q4).
class WatchSettings {
  const WatchSettings(this._settings);

  final SettingsRepository _settings;

  Stream<AppSettings> call() => _settings.watch();
}
