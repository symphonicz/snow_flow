import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:snow_flow/core/l10n/app_localizations.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';
import 'package:snow_flow/shared/presentation/icons/app_icons.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

/// Success uses `income`, error `expense`, info `brand` (#20).
enum ToastKind { success, error, info }

/// Shows [message] as the app's floating toast, replacing any toast still
/// showing. Every result message in the app goes through here, never a
/// SnackBar (#20). Only an error may offer [onRetry].
void showToast(
  BuildContext context,
  String message, {
  ToastKind kind = ToastKind.success,
  VoidCallback? onRetry,
}) {
  assert(
    onRetry == null || kind == ToastKind.error,
    'Only an error toast offers "try again" (#20).',
  );
  final host = context.findAncestorStateOfType<_ToastHostState>();
  assert(host != null, 'Put a ToastHost in MaterialApp.builder.');
  host?._show(_Toast(message, kind, onRetry));
}

/// Floats toasts above everything [child] shows, dialogs and sheets
/// included. Goes in `MaterialApp.builder`, above the navigator.
class ToastHost extends StatefulWidget {
  const ToastHost({super.key, required this.child});

  final Widget child;

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _Toast {
  _Toast(this.message, this.kind, this.onRetry);

  final String message;
  final ToastKind kind;
  final VoidCallback? onRetry;

  Duration get shownFor => kind == ToastKind.error
      ? const Duration(seconds: 6)
      : const Duration(seconds: 4);
}

class _ToastHostState extends State<ToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  _Toast? _toast;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Not a lazy field: a host that never showed a toast would otherwise
    // create its ticker in dispose, after it left the tree.
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _show(_Toast toast) {
    _timer?.cancel();
    setState(() => _toast = toast);
    if (_reduceMotion) {
      _motion.value = 1;
    } else {
      _motion.forward(from: 0);
    }
    _timer = Timer(toast.shownFor, _hide);
    SemanticsService.announce(toast.message, Directionality.of(context));
  }

  /// Slides the toast out; a newer toast shown meanwhile stays.
  void _hide() {
    final toast = _toast;
    if (toast == null) return;
    _timer?.cancel();
    if (_reduceMotion) return _remove();
    _motion.reverse().then((_) {
      if (mounted && identical(_toast, toast)) _remove();
    });
  }

  void _remove() {
    _timer?.cancel();
    setState(() => _toast = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toast = _toast;
    return Stack(
      fit: StackFit.expand,
      children: [widget.child, if (toast != null) _placed(context, toast)],
    );
  }

  /// Mobile: top, below the safe area, swipe up to close. Web: top right
  /// corner (#20).
  Widget _placed(BuildContext context, _Toast toast) {
    final media = MediaQuery.of(context);
    final web = media.size.width >= AppSizes.webBreakpoint;
    final motion = CurvedAnimation(parent: _motion, curve: Curves.easeOutCubic);
    final card = FadeTransition(
      opacity: motion,
      child: SlideTransition(
        position: Tween(
          begin: web ? const Offset(1.2, 0) : const Offset(0, -1.2),
          end: Offset.zero,
        ).animate(motion),
        child: _ToastCard(
          toast: toast,
          onClose: _hide,
          onRetry: toast.onRetry == null
              ? null
              : () {
                  _hide();
                  toast.onRetry!();
                },
        ),
      ),
    );
    if (web) {
      return Positioned(
        top: media.padding.top + AppSpacing.s20,
        right: AppSpacing.s20,
        width: math.min(
          AppSizes.toastMaxWidth,
          media.size.width - AppSpacing.s20 * 2,
        ),
        child: card,
      );
    }
    return Positioned(
      top: media.padding.top + AppSpacing.s12,
      left: AppSpacing.s12,
      right: AppSpacing.s12,
      child: Dismissible(
        key: ObjectKey(toast),
        direction: DismissDirection.up,
        resizeDuration: null,
        onDismissed: (_) => _remove(),
        child: card,
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.toast,
    required this.onClose,
    required this.onRetry,
  });

  final _Toast toast;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final (background, icon) = switch (toast.kind) {
      ToastKind.success => (colors.income, AppIcons.circleCheck),
      ToastKind.error => (colors.expense, AppIcons.circleAlert),
      ToastKind.info => (colors.brand, AppIcons.info),
    };
    // on-brand reads on all three backgrounds: white in light, dark ink in
    // dark (#20).
    final foreground = colors.onBrand;
    final text = AppText.body.copyWith(color: foreground);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.card(Theme.of(context).brightness),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: AppSpacing.s16,
            top: AppSpacing.s4,
            bottom: AppSpacing.s4,
            end: AppSpacing.s4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [
              _TouchHigh(
                child: _ToastIcon(icon: icon, color: foreground),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TouchHigh(child: Text(toast.message, style: text)),
                    if (onRetry != null)
                      TextButton(
                        onPressed: onRetry,
                        style: TextButton.styleFrom(
                          foregroundColor: foreground,
                          textStyle: AppText.amount,
                          minimumSize: const Size(0, AppSizes.minTouch),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(l10n.commonTryAgain),
                      ),
                  ],
                ),
              ),
              Semantics(
                container: true,
                button: true,
                label: l10n.toastClose,
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onClose,
                  radius: AppSizes.minTouch / 2,
                  child: SizedBox.square(
                    dimension: AppSizes.minTouch,
                    child: Center(
                      child: _ToastIcon(
                        icon: AppIcons.close,
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// At least one touch target high, content centred, so the icon, the first
/// line of text and the ✕ line up.
class _TouchHigh extends StatelessWidget {
  const _TouchHigh({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minHeight: AppSizes.minTouch),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: child,
    ),
  );
}

class _ToastIcon extends StatelessWidget {
  const _ToastIcon({required this.icon, required this.color});

  final List<IconShape> icon;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      LineIcon(icon, size: AppSizes.iconSmall, color: color);
}
