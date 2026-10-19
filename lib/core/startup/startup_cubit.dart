import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/startup_state.dart';
import 'package:snow_flow/core/startup/tab_lock.dart';

/// Opens the stored data before the first page (#56): one tab at a time on
/// web, and broken data stops at a problem screen instead of being deleted.
class StartupCubit extends Cubit<StartupState> {
  StartupCubit({required TabLock tabLock, required AppStorage storage})
    : _tabLock = tabLock,
      _storage = storage,
      super(const StartupLoading()) {
    _lostSubscription = _tabLock.lost.listen((_) => _onLost());
  }

  final TabLock _tabLock;
  final AppStorage _storage;
  late final StreamSubscription<void> _lostSubscription;
  bool _hasTab = false;

  /// True while a step runs. Another tap is ignored, and a lost tab closes
  /// the storage once the step ends rather than in the middle of it.
  bool _busy = false;

  Future<void> start() => _claimTabAndOpen();

  /// "Use it in this tab instead": the other tab stops saving.
  Future<void> takeOver() => _claimTabAndOpen(takeOver: true);

  Future<void> retry() => _run(_storage.open);

  /// Deletes only what is broken. The screen asks the user to confirm first.
  Future<void> startOver() async {
    final current = state;
    if (current is! StartupUnreadable) return;
    await _run(() => _storage.startOver(current.broken));
  }

  Future<void> _claimTabAndOpen({bool takeOver = false}) => _run(() async {
    _hasTab = await _tabLock.acquire(takeOver: takeOver);
    return _hasTab ? _storage.open() : null;
  });

  /// Runs [step]; a null status means the tab lock was refused.
  Future<void> _run(Future<StorageStatus?> Function() step) async {
    if (_busy) return;
    _busy = true;
    // Cubit lets a first emit through even when it equals the initial state.
    if (state is! StartupLoading) emit(const StartupLoading());
    StorageStatus? status;
    try {
      status = await step();
    } catch (error, stackTrace) {
      // A bug, not a storage problem: report it, but never leave the user
      // on a blank screen with no button.
      addError(error, stackTrace);
      status = const StorageCannotOpen();
    } finally {
      _busy = false;
    }
    if (!_hasTab) {
      // Refused, or another tab took over while this one was opening.
      if (status != null) await _storage.close();
      return emit(const StartupOtherTab());
    }
    emit(switch (status) {
      StorageReady() => const StartupReady(),
      StorageCannotOpen() => const StartupUnavailable(),
      StorageBroken(:final broken) => StartupUnreadable(broken),
      null => const StartupOtherTab(),
    });
  }

  Future<void> _onLost() async {
    _hasTab = false;
    // The gate drops the app on this state. Closing also turns any write
    // still on its way into a failed write, so this tab stops saving.
    emit(const StartupOtherTab());
    if (!_busy) await _storage.close();
  }

  @override
  Future<void> close() async {
    await _lostSubscription.cancel();
    return super.close();
  }
}
