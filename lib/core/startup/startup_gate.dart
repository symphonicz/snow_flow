import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snow_flow/core/startup/app_storage.dart';
import 'package:snow_flow/core/startup/startup_cubit.dart';
import 'package:snow_flow/core/startup/startup_state.dart';
import 'package:snow_flow/core/startup/startup_texts.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

/// Shows the app only once [cubit] is ready, and a startup screen otherwise
/// (#56). The app is built fresh each time it becomes ready, because coming
/// back from another tab registers everything again.
class StartupGate extends StatefulWidget {
  const StartupGate({
    super.key,
    required this.cubit,
    required this.buildApp,
    this.isWeb = kIsWeb,
  });

  final StartupCubit cubit;
  final Widget Function() buildApp;

  /// Shows the private window tip; a parameter so tests can turn it on.
  final bool isWeb;

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  Widget? _app;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StartupCubit, StartupState>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (state is StartupReady) return _app ??= widget.buildApp();
        _app = null;
        return _StartupApp(
          state: state,
          cubit: widget.cubit,
          isWeb: widget.isWeb,
        );
      },
    );
  }
}

/// Its own [MaterialApp]: these screens show before the app's theme, router
/// and settings exist, so they follow the device's brightness and language.
/// Light and dark come from the theme file of #51.
class _StartupApp extends StatelessWidget {
  const _StartupApp({
    required this.state,
    required this.cubit,
    required this.isWeb,
  });

  final StartupState state;
  final StartupCubit cubit;
  final bool isWeb;

  @override
  Widget build(BuildContext context) {
    final texts = StartupTexts.of(View.of(context).platformDispatcher.locale);
    return MaterialApp(
      title: 'SnowFlow',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Scaffold(
        body: switch (state) {
          StartupLoading() || StartupReady() => const SizedBox.shrink(),
          StartupOtherTab() => _StartupMessage(
            icon: AppIcons.appWindow,
            title: texts.otherTabTitle,
            body: texts.otherTabBody,
            actions: [
              FilledButton(
                onPressed: cubit.takeOver,
                child: Text(texts.useHere),
              ),
            ],
          ),
          StartupUnavailable() => _StartupMessage(
            icon: AppIcons.database,
            title: texts.unavailableTitle,
            body: isWeb
                ? '${texts.unavailableBody} ${texts.privateWindowTip}'
                : texts.unavailableBody,
            actions: [
              FilledButton(onPressed: cubit.retry, child: Text(texts.tryAgain)),
            ],
          ),
          StartupUnreadable(:final broken) => _StartupMessage(
            icon: AppIcons.circleAlert,
            title: texts.unreadableTitle,
            body: texts.unreadableBody(broken),
            actions: [
              FilledButton(onPressed: cubit.retry, child: Text(texts.tryAgain)),
              // The import button of #66 goes here.
              _StartOverButton(texts: texts, broken: broken, cubit: cubit),
            ],
          ),
        },
      ),
    );
  }
}

class _StartOverButton extends StatelessWidget {
  const _StartOverButton({
    required this.texts,
    required this.broken,
    required this.cubit,
  });

  final StartupTexts texts;
  final Set<StoredData> broken;
  final StartupCubit cubit;

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts.confirmTitle),
        content: Text(texts.confirmBody(broken)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(texts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: _deleteStyle(context),
            child: Text(texts.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await cubit.startOver();
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _confirm(context),
      style: _deleteStyle(context),
      child: Text(texts.startOver, textAlign: TextAlign.center),
    );
  }

  /// Marks the buttons that delete data with the `expense` token.
  static ButtonStyle _deleteStyle(BuildContext context) =>
      TextButton.styleFrom(foregroundColor: AppColors.of(context).expense);
}

/// Icon, title, text and buttons, centred and scrollable so a narrow screen
/// or large text never overflows.
class _StartupMessage extends StatelessWidget {
  const _StartupMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
  });

  final List<IconShape> icon;
  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.messageMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.s12,
              children: [
                LineIcon(icon, size: AppSizes.iconLarge),
                Text(
                  title,
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  body,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s12),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
