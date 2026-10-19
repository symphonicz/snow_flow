import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/core/storage/box_names.dart';
import 'package:snow_flow/core/storage/storage_open_failed.dart';
import 'package:snow_flow/core/storage/storage_persistence.dart';

/// Registers technical services (theme, localization, formatters, hive_ce).
/// Hive must already be initialised. Each box is registered open under its
/// [BoxNames] name for `registerShared`; a box that cannot be opened throws
/// [StorageOpenFailed].
Future<void> registerCore(GetIt getIt) async {
  getIt.registerSingleton(await storagePersistence);
  for (final name in BoxNames.all) {
    getIt.registerSingleton<Box<dynamic>>(
      await _openBox(name),
      instanceName: name,
    );
  }
}

Future<Box<dynamic>> _openBox(String name) async {
  try {
    return await Hive.openBox<dynamic>(name);
  } catch (error) {
    // Plain JS objects too: a blocked IndexedDB does not throw Dart errors.
    throw StorageOpenFailed(name, error);
  }
}
