import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Turns the daily reminder on or off and sets its time in one step, so the
/// reminder can be rescheduled in one place (#21).
class SetReminder {
  const SetReminder(this._settings);

  final SettingsRepository _settings;

  Future<Either<Failure, Unit>> call({
    required bool remind,
    required ReminderTime time,
  }) => _settings.update(
    (settings) => settings.copyWith(remind: remind, remindTime: time),
  );
}
