import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/injection.dart';
import 'package:snow_flow/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  // Web keeps Flutter's default `#` URLs (no usePathUrlStrategy) because
  // GitHub Pages cannot rewrite paths, so refreshing would 404 (ADR 0003).
  runApp(SnowFlowApp(router: createRouter()));
}

class SnowFlowApp extends StatelessWidget {
  const SnowFlowApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'SnowFlow', routerConfig: router);
  }
}
