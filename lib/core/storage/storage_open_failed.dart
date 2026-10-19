/// A hive_ce box could not be opened, e.g. IndexedDB is blocked in a private
/// window or the disk is full. [registerCore] stops there, so nothing after
/// it is registered (#18 Q5.1).
class StorageOpenFailed implements Exception {
  const StorageOpenFailed(this.box, this.cause);

  final String box;
  final Object cause;

  @override
  String toString() => 'StorageOpenFailed($box): $cause';
}
