import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/storage/box_names.dart';
import 'package:snow_flow/core/storage/storage_open_failed.dart';
import 'package:snow_flow/shared/domain/failure.dart';
import 'package:snow_flow/shared/domain/usecases/get_entries.dart';
import 'package:snow_flow/shared/domain/usecases/get_settings.dart';

/// [AppStorage] on hive_ce. Every [open] starts from an empty [GetIt] and
/// runs [configure] (the composition root), so retrying or coming back from
/// another tab never reuses a closed box.
class HiveAppStorage implements AppStorage {
  HiveAppStorage({
    required GetIt getIt,
    required Future<void> Function(GetIt) configure,
    Future<void> Function()? initHive,
  }) : _getIt = getIt,
       _configure = configure,
       _initHive = initHive ?? Hive.initFlutter;

  static const _boxNames = {
    StoredData.entries: BoxNames.entries,
    StoredData.settings: BoxNames.settings,
  };

  final GetIt _getIt;
  final Future<void> Function(GetIt) _configure;
  final Future<void> Function() _initHive;
  bool _hiveReady = false;

  @override
  Future<StorageStatus> open() async {
    await close();
    if (!_hiveReady) {
      try {
        await _initHive();
      } catch (_) {
        // No app folder to keep the boxes in, or similar.
        return const StorageCannotOpen();
      }
      _hiveReady = true;
    }
    try {
      await _configure(_getIt);
    } on StorageOpenFailed {
      return const StorageCannotOpen();
    }
    return _readEverything();
  }

  /// Reads all of it once, so a broken entry is found now (#16 Q4).
  Future<StorageStatus> _readEverything() async {
    final failures = {
      StoredData.entries: (await _getIt<GetEntries>()()).getLeft(),
      StoredData.settings: (await _getIt<GetSettings>()()).getLeft(),
    };
    if (failures.values.any((f) => f.toNullable() is StorageUnavailable)) {
      return const StorageCannotOpen();
    }
    final broken = {
      for (final MapEntry(:key, :value) in failures.entries)
        if (value.toNullable() is StorageUnreadable) key,
    };
    return broken.isEmpty ? const StorageReady() : StorageBroken(broken);
  }

  @override
  Future<StorageStatus> startOver(Set<StoredData> broken) async {
    // Straight on the boxes, not through a repository or use case: the
    // repositories read before they write, and this data cannot be read.
    try {
      for (final data in broken) {
        await _getIt<Box<dynamic>>(instanceName: _boxNames[data]).clear();
      }
    } catch (error) {
      if (error is Error && error is! HiveError) rethrow;
      return const StorageCannotOpen();
    }
    return open();
  }

  @override
  Future<void> close() async {
    await _getIt.reset();
    await Hive.close();
  }
}
