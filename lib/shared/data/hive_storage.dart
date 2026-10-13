/// Turns hive_ce errors into [Failure]s for the hive repositories.
library;

import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:snow_flow/shared/domain/failure.dart';

/// Runs [action], mapping a broken map ([FormatException] from `fromMap`) to
/// [StorageUnreadable] and a box that cannot be used to [StorageUnavailable].
Future<Either<Failure, T>> guardStorage<T>(
  FutureOr<Either<Failure, T>> Function() action,
) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    return Left(_failureFor(error, stackTrace));
  }
}

/// [read] now and after every change to [box]. A failed read goes out as a
/// stream error and the stream keeps going (#18 Q4).
Stream<T> watchBox<T>(Box<dynamic> box, T Function() read) =>
    Stream.multi((controller) {
      void emit() {
        try {
          controller.add(read());
        } catch (error, stackTrace) {
          controller.addError(_failureFor(error, stackTrace));
        }
      }

      // Listen before the first read so no change slips in between.
      final changes = box.watch().listen((_) => emit());
      controller.onCancel = changes.cancel;
      emit();
    });

/// The stored value as a map, or [FormatException] so it counts as broken.
Map<dynamic, dynamic> requireMap(Object? value) => value is Map
    ? value
    : throw FormatException('Expected a map, got ${value.runtimeType}');

/// Any other Dart [Error] is a bug in our code, not a storage problem, so it
/// is rethrown. Non-Dart objects are caught because a blocked IndexedDB on
/// web throws plain JS objects.
Failure _failureFor(Object error, StackTrace stackTrace) => switch (error) {
  FormatException() => const StorageUnreadable(),
  HiveError() => const StorageUnavailable(),
  Error() => Error.throwWithStackTrace(error, stackTrace),
  _ => const StorageUnavailable(),
};
