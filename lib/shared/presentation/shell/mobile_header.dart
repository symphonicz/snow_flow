import 'package:flutter/material.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/presentation/app_logo.dart';

/// The top of a mobile screen (brief §7): an optional [leading] button, the
/// [title], and an optional [trailing] button on the right.
class MobileHeader extends StatelessWidget {
  const MobileHeader({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
  });

  final Widget? leading;
  final Widget title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // A button already pads its icon, so the screen edge shrinks by that
    // much next to one and the icon lines up with the content.
    const buttonInset = (kMinInteractiveDimension - AppSizes.icon) / 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        leading == null
            ? AppSpacing.screenEdge
            : AppSpacing.screenEdge - buttonInset,
        AppSpacing.s8,
        trailing == null
            ? AppSpacing.screenEdge
            : AppSpacing.screenEdge - buttonInset,
        AppSpacing.s8,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
        child: Row(
          spacing: AppSpacing.s4,
          children: [
            ?leading,
            Expanded(
              child: DefaultTextStyle.merge(
                style: AppText.pageTitleMobile.copyWith(
                  color: AppColors.of(context).ink,
                ),
                child: Semantics(header: true, child: title),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// The logo and "SnowFlow", the title of the entries page.
class MobileBrandTitle extends StatelessWidget {
  const MobileBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: AppSpacing.s12,
      children: [
        AppLogo(),
        Flexible(child: Text('SnowFlow')),
      ],
    );
  }
}
