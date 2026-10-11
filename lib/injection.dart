import 'package:get_it/get_it.dart';
import 'package:snow_flow/core/core_injection.dart';
import 'package:snow_flow/shared/shared_injection.dart';

/// Composition root for get_it: registers core → shared → every feature, in
/// that order. The only file besides `router.dart` allowed to import every
/// feature (ADR 0003).
void configureDependencies([GetIt? getIt]) {
  final locator = getIt ?? GetIt.instance;
  registerCore(locator);
  registerShared(locator);
}
