import 'package:flutter/widgets.dart';
import 'package:snow_flow/core/theme/app_theme.dart';

/// The 2 px brand ring of brief §8 around the amount field and the chosen
/// category: a brand fill whose corners are [radius] + 2, showing around
/// [child], whose own fill has corners [radius]. Like the tint ring of the
/// add-entry button, so it is as thick at the corners as along the sides; a
/// spread shadow keeps [radius] on a bigger box and comes out thinner at the
/// corners (#61). Not a border: it marks a choice, it divides nothing (#37).
///
/// Takes its 2 px whether [visible] or not, so choosing never moves
/// anything.
class BrandRing extends StatelessWidget {
  const BrandRing({
    super.key,
    required this.radius,
    required this.child,
    this.visible = true,
  });

  final double radius;
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: visible ? AppColors.of(context).brand : null,
        borderRadius: BorderRadius.circular(radius + AppSizes.selectedRing),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.selectedRing),
        child: child,
      ),
    );
  }
}
