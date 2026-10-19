import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/shell/mobile_header.dart';

/// A mobile page stacked over the tabs, without the bottom bar (brief §7:
/// settings). The back button always shows: with nothing to go back to
/// (the page was opened straight from its URL) it goes to
/// [fallbackLocation] instead (#59 Q3).
class MobileStackedPage extends StatelessWidget {
  const MobileStackedPage({
    super.key,
    required this.title,
    required this.fallbackLocation,
    required this.child,
  });

  final String title;
  final String fallbackLocation;
  final Widget child;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MobileHeader(
              leading: IconButton(
                onPressed: () => _back(context),
                tooltip: AppLocalizations.of(context).commonBack,
                icon: const LineIcon(AppIcons.back),
              ),
              title: Text(title),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
