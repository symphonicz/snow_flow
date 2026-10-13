import 'package:equatable/equatable.dart';

/// Why a use case could not finish (#18 Q4). Each kind gets its own message
/// on screen, so add a subclass rather than a flag.
sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object> get props => const [];
}

/// A stored map is broken (missing field, wrong type). Show the problem
/// screen; never delete the data (#16).
final class StorageUnreadable extends Failure {
  const StorageUnreadable();
}

/// The box could not be read or written, e.g. IndexedDB is full or blocked.
final class StorageUnavailable extends Failure {
  const StorageUnavailable();
}

/// `add` found an entry with the same id; nothing was overwritten (#55).
final class EntryAlreadyExists extends Failure {
  const EntryAlreadyExists();
}

/// `update` found no entry with that id; nothing was created (#55).
final class EntryNotFound extends Failure {
  const EntryNotFound();
}
