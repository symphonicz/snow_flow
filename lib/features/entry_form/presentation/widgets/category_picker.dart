import 'package:flutter/material.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/features/entry_form/presentation/widgets/brand_ring.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/category_name.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';
import 'package:snow_flow/shared/presentation/shrink_to_fit.dart';

/// The form's category grid (brief §8): four to a row, each a surface-2
/// button; the chosen one is on tint inside the brand ring (#61 Q1).
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<EntryCategory> categories;
  final EntryCategory selected;
  final ValueChanged<EntryCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    const columns = AppSizes.categoryColumns;
    return Column(
      spacing: AppSpacing.s8,
      children: [
        for (var start = 0; start < categories.length; start += columns)
          Row(
            spacing: AppSpacing.s8,
            children: [
              for (var i = start; i < start + columns; i++)
                Expanded(
                  child: i < categories.length
                      ? _CategoryButton(
                          category: categories[i],
                          selected: categories[i] == selected,
                          onTap: () => onSelected(categories[i]),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
      ],
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final EntryCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(AppRadius.md);
    return Semantics(
      button: true,
      selected: selected,
      child: BrandRing(
        radius: AppRadius.md,
        visible: selected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.tint : colors.surface2,
            borderRadius: radius,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: SizedBox(
                // 78 with the ring around it (brief §8).
                height: AppSizes.categoryButton - 2 * AppSizes.selectedRing,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: AppSpacing.s4,
                    children: [
                      CategoryIcon(category),
                      // Never cut, so a long name such as "บิล/ค่าน้ำไฟ"
                      // shrinks to fit the cell (#37).
                      ShrinkToFit(
                        alignment: Alignment.center,
                        child: Text(
                          categoryName(AppLocalizations.of(context), category),
                          style: AppText.label.copyWith(
                            color: selected ? colors.brand : colors.ink2,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
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
