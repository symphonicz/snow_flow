import 'package:equatable/equatable.dart';
import 'package:snow_flow/core/startup/app_storage.dart';

/// Which screen shows before (or instead of) the app (#56).
sealed class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object> get props => const [];
}

final class StartupLoading extends StartupState {
  const StartupLoading();
}

/// The app is in use in another tab; offer to use it here instead.
final class StartupOtherTab extends StartupState {
  const StartupOtherTab();
}

/// The storage cannot be opened at all; only "try again" helps.
final class StartupUnavailable extends StartupState {
  const StartupUnavailable();
}

/// [broken] cannot be read; offer "try again" and "start over".
final class StartupUnreadable extends StartupState {
  const StartupUnreadable(this.broken);

  final Set<StoredData> broken;

  @override
  List<Object> get props => [broken];
}

final class StartupReady extends StartupState {
  const StartupReady();
}
