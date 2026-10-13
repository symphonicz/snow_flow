import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/settings_repository.dart';

/// Sets the day each month cycle starts (brief §4.4).
class SetCycleStartDay {
  const SetCycleStartDay(this._settings);

  final SettingsRepository _settings;

  /// Throws [RangeError] for a day outside 1–31: the picker offers only those,
  /// so another day is a bug, not something to show the user.
  Future<Either<Failure, Unit>> call(int day) {
    RangeError.checkValueInInterval(day, 1, 31, 'day');
    return _settings.update(
      (settings) => settings.copyWith(cycleStartDay: day),
    );
  }
}
