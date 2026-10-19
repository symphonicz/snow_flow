import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/presentation/icons/line_icon.dart';

/// The app icon of brief §9 (the round bird), drawn from its SVG so no
/// package or image file is needed (#59 Q4). The launcher icons of #71 come
/// from the same SVG: change the bird in both places.
///
/// Decoration: the "SnowFlow" next to it is what screen readers read.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = AppSizes.logo});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _BirdPainter()),
      ),
    );
  }
}

/// Paints the SVG on its 100×100 view box, so the numbers below (the 23
/// corner too) are SVG units, not design tokens.
class _BirdPainter extends CustomPainter {
  const _BirdPainter();

  static final _tail = svgPath('M66 66 86 84M62 70 81 89');
  static final _leftWing = svgPath(
    'M19.5 52c1 10 7 18 16 21-3-6-4-13-3-19-5-2-9-2-13-2Z',
  );
  static final _rightWing = svgPath(
    'M74.5 52c-1 10-7 18-16 21 3-6 4-13 3-19 5-2 9-2 13-2Z',
  );
  static final _beak = svgPath('M45 51h4L47 53.8Z');

  @override
  void paint(Canvas canvas, Size size) {
    const box = Rect.fromLTWH(0, 0, 100, 100);
    Paint fill(Color color) => Paint()..color = color;

    canvas.scale(size.shortestSide / 100);
    canvas.clipRRect(RRect.fromRectAndRadius(box, const Radius.circular(23)));
    canvas.drawRect(box, fill(AppLogoColors.paper));
    canvas.drawPath(
      _tail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = AppLogoColors.ink,
    );

    // The body is tilted −13° about (47, 50), like the SVG's group.
    canvas
      ..translate(47, 50)
      ..rotate(-13 * math.pi / 180)
      ..translate(-47, -50);
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(47, 53), width: 56, height: 51),
        fill(AppLogoColors.shade),
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(47, 50), width: 56, height: 51),
        fill(AppLogoColors.paper),
      )
      ..drawPath(_leftWing, fill(AppLogoColors.wing))
      ..drawPath(_rightWing, fill(AppLogoColors.wing))
      ..drawCircle(const Offset(39.5, 46), 3, fill(AppLogoColors.ink))
      ..drawCircle(const Offset(54.5, 46), 3, fill(AppLogoColors.ink))
      ..drawPath(_beak, fill(AppLogoColors.ink));
  }

  @override
  bool shouldRepaint(_BirdPainter old) => false;
}
