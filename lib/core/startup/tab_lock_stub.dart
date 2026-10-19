import 'package:snow_flow/core/startup/tab_lock.dart';

/// Apps have no tabs, so the lock is always free and never lost.
class PlatformTabLock implements TabLock {
  @override
  Future<bool> acquire({bool takeOver = false}) async => true;

  @override
  Stream<void> get lost => const Stream.empty();
}
