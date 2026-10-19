import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/shell/mobile_header.dart';

/// The mobile layout (brief §7, #18 Q6): a header with the settings gear,
/// the tab's page, and a bottom bar of entries | add entry | summary.
///
/// [navigationShell] must have two branches, entries first and summary
/// second. What the buttons do comes from the router, because `shared/` may
/// not import the features they open.
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.navigationShell,
    required this.onAddEntry,
    required this.onOpenSettings,
  });

  static const entriesTab = 0;
  static const summaryTab = 1;

  final StatefulNavigationShell navigationShell;
  final void Function(BuildContext context) onAddEntry;
  final void Function(BuildContext context) onOpenSettings;

  /// Tapping the open tab again takes it back to its first page.
  void _goTab(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tab = navigationShell.currentIndex;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MobileHeader(
              title: tab == entriesTab
                  ? const MobileBrandTitle()
                  : Text(l10n.commonSummary),
              trailing: IconButton(
                onPressed: () => onOpenSettings(context),
                tooltip: l10n.commonSettings,
                icon: const LineIcon(AppIcons.settings),
              ),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        tab: tab,
        onTab: _goTab,
        onAddEntry: () => onAddEntry(context),
      ),
    );
  }
}

/// The add-entry button and its ring rise this far above the bar.
const _barLift = AppSizes.addLift + AppSizes.addRing;

/// Space between the bottom of the bar and the labels.
const _barBottom = AppSpacing.s12;

/// Space above a tab's icon. The bar's row lines its slots up at the
/// bottom, so this makes a tab exactly [_barLift] shorter than the add
/// button's slot and the bar starts where the tabs do.
const _tabTop =
    AppSizes.addButton + 2 * AppSizes.addRing - AppSizes.icon - _barLift;

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tab,
    required this.onTab,
    required this.onAddEntry,
  });

  final int tab;
  final ValueChanged<int> onTab;
  final VoidCallback onAddEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return Stack(
      children: [
        // The bar itself starts below the raised button; above it the page
        // background shows through.
        Positioned.fill(
          top: _barLift,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: AppShadows.bar,
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _Tab(
                    icon: AppIcons.entries,
                    label: l10n.commonEntries,
                    selected: tab == MobileShell.entriesTab,
                    onTap: () => onTab(MobileShell.entriesTab),
                  ),
                ),
                Expanded(child: _AddButton(onPressed: onAddEntry)),
                Expanded(
                  child: _Tab(
                    icon: AppIcons.summary,
                    label: l10n.commonSummary,
                    selected: tab == MobileShell.summaryTab,
                    onTap: () => onTab(MobileShell.summaryTab),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final List<IconShape> icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = selected ? colors.brand : colors.ink3;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s4,
            _tabTop,
            AppSpacing.s4,
            _barBottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s4,
            children: [
              LineIcon(icon, color: color),
              Text(
                label,
                style: AppText.label.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The raised pencil button with "Add entry" under it (brief §7). The label
/// opens the form too.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = AppLocalizations.of(context).commonAddEntry;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(bottom: _barBottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s4,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.tint,
                    borderRadius: BorderRadius.circular(
                      AppRadius.lg + AppSizes.addRing,
                    ),
                    boxShadow: AppShadows.add,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.addRing),
                    child: Material(
                      color: colors.brand,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: InkWell(
                        onTap: onPressed,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: SizedBox.square(
                          dimension: AppSizes.addButton,
                          child: Center(
                            child: LineIcon(
                              AppIcons.pencil,
                              color: colors.onBrand,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  label,
                  style: AppText.labelBold.copyWith(color: colors.brand),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
