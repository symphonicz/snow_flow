import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:snow_flow/features/settings/domain/usecases/set_cycle_start_day.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';

import '../../../../helpers/fakes/in_memory_settings_repository.dart';

void main() {
  late InMemorySettingsRepository settings;
  late SetCycleStartDay setCycleStartDay;

  setUp(() {
    settings = InMemorySettingsRepository();
    setCycleStartDay = SetCycleStartDay(settings);
  });

  test('saves a day from 1 to 31', () async {
    for (final day in [1, 25, 31]) {
      expect(await setCycleStartDay(day), right(unit));
      expect(
        (await settings.get()).toNullable(),
        AppSettings(cycleStartDay: day),
      );
    }
  });

  test('throws for a day outside 1–31 and saves nothing', () async {
    expect(() => setCycleStartDay(0), throwsRangeError);
    expect(() => setCycleStartDay(32), throwsRangeError);
    expect((await settings.get()).toNullable(), const AppSettings());
  });
}
