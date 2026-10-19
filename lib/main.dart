import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/l10n/app_locale.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/startup/hive_app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_gate.dart';
import 'package:snow_flow/core/startup/tab_lock.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/injection.dart';
import 'package:snow_flow/router.dart';
import 'package:snow_flow/shared/domain/app_settings.dart';
import 'package:snow_flow/shared/domain/usecases/watch_settings.dart';
import 'package:snow_flow/shared/presentation/app_settings/app_settings_cubit.dart';
import 'package:snow_flow/shared/presentation/toast/toast.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  // Opens the storage before the first page; registers everything through
  // configureDependencies once this tab may use it (#56).
  final startup = StartupCubit(
    tabLock: TabLock(),
    storage: HiveAppStorage(
      getIt: GetIt.instance,
      configure: configureDependencies,
    ),
  )..start();
  // The bundled fonts load while the storage opens, so the first frame
  // never flashes a fallback font (#51).
  await loadAppFonts();
  // Web keeps Flutter's default `#` URLs (no usePathUrlStrategy) because
  // GitHub Pages cannot rewrite paths, so refreshing would 404 (ADR 0003).
  runApp(
    StartupGate(
      cubit: startup,
      buildApp: () =>
          SnowFlowApp(router: createRouter(), watchSettings: GetIt.instance()),
    ),
  );
}

class SnowFlowApp extends StatelessWidget {
  const SnowFlowApp({
    super.key,
    required this.router,
    required this.watchSettings,
  });

  final GoRouter router;
  final WatchSettings watchSettings;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppSettingsCubit(watchSettings)..start(),
      child: BlocBuilder<AppSettingsCubit, AppSettings?>(
        builder: (context, settings) {
          // Nothing until the settings are read, so a picked language never
          // shows after a flash of the device one (#52).
          if (settings == null) return const SizedBox.shrink();
          return MaterialApp.router(
            title: 'SnowFlow',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            // Follows the device until #65 wires in the theme setting.
            themeMode: ThemeMode.system,
            // Null follows the device, which changes the app at once when
            // the device language changes (#14).
            locale: pickedLocale(settings.lang),
            localeListResolutionCallback: (device, _) => deviceLocale(device),
            supportedLocales: appLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => ToastHost(child: child!),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
