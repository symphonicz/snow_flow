import 'package:snow_flow/core/startup/tab_lock_stub.dart'
    if (dart.library.js_interop) 'package:snow_flow/core/startup/tab_lock_web.dart';

/// Lets only one browser tab use the stored data at a time (#16 Q3).
abstract interface class TabLock {
  /// The lock for this platform: Web Locks on web, always free elsewhere.
  factory TabLock() = PlatformTabLock;

  /// True when this tab now holds the lock. Without [takeOver] it gives up
  /// if another tab holds it; with [takeOver] it takes it from that tab.
  Future<bool> acquire({bool takeOver = false});

  /// Fires when another tab took the lock away from this one.
  Stream<void> get lost;
}
