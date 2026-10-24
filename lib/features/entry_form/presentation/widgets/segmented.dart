import 'package:flutter/material.dart';
import 'package:snow_flow/core/theme/app_theme.dart';

/// The app's segmented control (brief §8): a surface-2 track, the selected
/// segment on surface with the card shadow and bold text. No lines between
/// segments (#37).
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  /// Each value with its label, in order.
  final List<(T, String)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.segmented),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.segmentedPadding),
        child: Row(
          children: [
            for (final (value, label) in segments)
              Expanded(
                child: _Segment(
                  label: label,
                  selected: value == selected,
                  onTap: () => onChanged(value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(AppRadius.segment);
    return Semantics(
      button: true,
      selected: selected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.surface : null,
          borderRadius: radius,
          boxShadow: selected
              ? AppShadows.card(Theme.of(context).brightness)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSizes.segment),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: (selected ? AppText.bodyBold : AppText.body).copyWith(
                    color: selected ? colors.ink : colors.ink2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
