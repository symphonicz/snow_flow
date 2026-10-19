import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:snow_flow/core/startup/tab_lock.dart';
import 'package:web/web.dart';

/// Holds a Web Lock for as long as the tab lives. The browser gives it back
/// when the tab closes or crashes (#16 Q3).
class PlatformTabLock implements TabLock {
  /// Every repo under `symphonicz.github.io` shares the origin, so the name
  /// has the app prefix like the box names (ADR 0001).
  static const name = 'snowflow_tab';

  final _lost = StreamController<void>.broadcast();

  @override
  Future<bool> acquire({bool takeOver = false}) {
    // Without Web Locks (old browser) one tab cannot be enforced; let it run.
    if (!window.navigator.has('locks')) return Future.value(true);

    final granted = Completer<bool>();
    JSPromise<JSAny?>? onGranted(Lock? lock) {
      granted.complete(lock != null);
      // A promise that never settles keeps the lock until the tab goes away.
      return lock == null ? null : Completer<JSAny?>().future.toJS;
    }

    // `steal` and `ifAvailable` cannot be set together.
    final options = takeOver
        ? LockOptions(steal: true)
        : LockOptions(ifAvailable: true);
    window.navigator.locks
        .request(name, options, onGranted.toJS)
        .toDart
        .then<void>(
          (_) {},
          onError: (Object _) {
            // Another tab stole the lock: the request fails with AbortError.
            if (granted.isCompleted) return _lost.add(null);
            // Locks refused outright (e.g. SecurityError): cannot enforce.
            granted.complete(true);
          },
        );
    return granted.future;
  }

  @override
  Stream<void> get lost => _lost.stream;
}
