import 'package:flutter/widgets.dart';

/// Shrinks a number that is too wide for its space, so every digit still
/// shows on one line: the balance card, the summary and EntryRow never cut a
/// number with "…" (#37). A number that fits keeps its size. Text or rich
/// text both work, e.g. a balance with a smaller currency symbol.
class ShrinkToFit extends StatelessWidget {
  const ShrinkToFit({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final Widget child;

  /// Where a number that fits sits; the reading edge unless told otherwise,
  /// e.g. `centerEnd` for the amount at the end of an EntryRow.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: child);
  }
}
