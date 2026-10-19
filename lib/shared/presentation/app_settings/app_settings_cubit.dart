import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';

/// The settings the whole app follows (language now, theme from #65), so a
/// change shows at once without a restart (#52). Null until the first read,
/// so the app never flashes the device language before a picked one.
class AppSettingsCubit extends Cubit<AppSettings?> {
  AppSettingsCubit(this._watchSettings) : super(null);

  final WatchSettings _watchSettings;
  StreamSubscription<AppSettings>? _subscription;

  void start() {
    _subscription ??= _watchSettings().listen(
      emit,
      // The startup check already read the settings, so this is rare. A
      // first read that fails falls back to the defaults (follow the
      // device); a later one keeps what is shown.
      onError: (Object _) {
        if (state == null) emit(const AppSettings());
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
