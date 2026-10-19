import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/startup/hive_app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_gate.dart';
import 'package:snow_flow/core/startup/tab_lock.dart';
import 'package:snow_flow/injection.dart';
import 'package:snow_flow/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Opens the storage before the first page; registers everything through
  // configureDependencies once this tab may use it (#56).
  final startup = StartupCubit(
    tabLock: TabLock(),
    storage: HiveAppStorage(
      getIt: GetIt.instance,
      configure: configureDependencies,
    ),
  )..start();
  // Web keeps Flutter's default `#` URLs (no usePathUrlStrategy) because
  // GitHub Pages cannot rewrite paths, so refreshing would 404 (ADR 0003).
  runApp(
    StartupGate(
      cubit: startup,
      buildApp: () => SnowFlowApp(router: createRouter()),
    ),
  );
}

class SnowFlowApp extends StatelessWidget {
  const SnowFlowApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'SnowFlow', routerConfig: router);
  }
}
