// Real Web Locks: run with `flutter test --platform chrome <this file>`.
@TestOn('browser')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:snow_flow/core/startup/tab_lock.dart';

void main() {
  // Each TabLock stands for one tab; the browser shares the lock by name.
  test('a second tab is refused, then takes over from the first', () async {
    final first = TabLock();
    final second = TabLock();
    var firstLost = false;
    first.lost.listen((_) => firstLost = true);

    expect(await first.acquire(), isTrue);
    expect(await second.acquire(), isFalse);
    expect(firstLost, isFalse);

    expect(await second.acquire(takeOver: true), isTrue);
    await pumpEventQueue();
    expect(firstLost, isTrue);

    // And the first tab can take it back the same way.
    var secondLost = false;
    second.lost.listen((_) => secondLost = true);
    expect(await first.acquire(takeOver: true), isTrue);
    await pumpEventQueue();
    expect(secondLost, isTrue);
  });
}
