import 'package:equatable/equatable.dart';

/// The stored data that can break on its own (one hive_ce box each).
enum StoredData { entries, settings }

/// What opening the stored data found.
sealed class StorageStatus extends Equatable {
  const StorageStatus();

  @override
  List<Object> get props => const [];
}

/// Everything opened and read; the app can start.
final class StorageReady extends StorageStatus {
  const StorageReady();
}

/// The storage cannot be opened at all, e.g. IndexedDB is blocked in a
/// private window. Nothing is known about which data is broken.
final class StorageCannotOpen extends StorageStatus {
  const StorageCannotOpen();
}

/// The storage opened but [broken] cannot be read. Nothing was deleted (#16).
final class StorageBroken extends StorageStatus {
  const StorageBroken(this.broken);

  final Set<StoredData> broken;

  @override
  List<Object> get props => [broken];
}

/// Opens and closes the app's stored data for the startup screens (#56).
abstract interface class AppStorage {
  /// Opens the storage, registers everything that needs it and reads all of
  /// it once, so broken data is found now and never skipped silently.
  /// Safe to call again after a failure or [close].
  Future<StorageStatus> open();

  /// Deletes only [broken] after the user confirmed, then opens again.
  Future<StorageStatus> startOver(Set<StoredData> broken);

  /// Stops using the storage, e.g. because another tab took over.
  Future<void> close();
}
