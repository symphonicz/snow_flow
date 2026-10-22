import 'package:get_it/get_it.dart';
import 'package:snow_flow/core/core_injection.dart';
import 'package:snow_flow/features/entries/entries_injection.dart';
import 'package:snow_flow/features/entry_form/entry_form_injection.dart';
import 'package:snow_flow/features/settings/settings_injection.dart';
import 'package:snow_flow/shared/shared_injection.dart';

/// Composition root for get_it: registers core → shared → every feature, in
/// that order. The only file besides `router.dart` allowed to import every
/// feature (ADR 0003). Opens the hive_ce boxes, so Hive must be initialised;
/// when a box cannot be opened nothing after core is registered (#18 Q5.1).
Future<void> configureDependencies([GetIt? getIt]) async {
  final locator = getIt ?? GetIt.instance;
  await registerCore(locator);
  registerShared(locator);
  registerEntries(locator);
  registerEntryForm(locator);
  registerSettings(locator);
}
