import 'package:flutter/material.dart';
import 'package:path_parsing/path_parsing.dart';
import 'package:snow_flow/core/theme/app_theme.dart';
import 'package:snow_flow/shared/domain/entry_category.dart';

/// Draws [shapes] on the 24×24 grid of brief §5/§6: a 1.8 stroke with
/// round caps and joins, no fill. Size and colour default to the
/// [IconTheme], like [Icon].
class LineIcon extends StatelessWidget {
  const LineIcon(
    this.shapes, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final List<IconShape> shapes;
  final double? size;
  final Color? color;

  /// Read out by screen readers; without it the icon is decoration.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final size = this.size ?? iconTheme.size ?? AppSizes.icon;
    // Like Icon: a parent that stretches the box (a stretched Column)
    // leaves the drawing centred at its own size.
    final icon = SizedBox.square(
      dimension: size,
      child: Center(
        child: SizedBox.square(
          dimension: size,
          child: CustomPaint(
            painter: _LineIconPainter(
              shapes,
              color ?? iconTheme.color ?? AppColors.of(context).ink,
            ),
          ),
        ),
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: icon)
        : Semantics(label: semanticLabel, child: icon);
  }
}

/// A category icon in the category colour of the current brightness.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon(this.category, {super.key, this.size});

  final EntryCategory category;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return LineIcon(
      category.icon,
      size: size,
      color: Color(dark ? category.darkColor : category.lightColor),
    );
  }
}

class _LineIconPainter extends CustomPainter {
  _LineIconPainter(this.shapes, this.color);

  static const _grid = 24.0;
  static final _paths = Expando<Path>();

  final List<IconShape> shapes;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / _grid;
    canvas.scale(scale);
    canvas.drawPath(
      _paths[shapes] ??= _toPath(shapes),
      Paint()
        ..style = PaintingStyle.stroke
        // The canvas is scaled, so undo it for the stroke: 1.8 px at any
        // icon size.
        ..strokeWidth = AppSizes.iconStroke / scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_LineIconPainter old) =>
      old.shapes != shapes || old.color != color;

  static Path _toPath(List<IconShape> shapes) {
    final path = Path();
    for (final shape in shapes) {
      switch (shape) {
        case PathShape(:final data):
          writeSvgPathDataToPath(data, _PathWriter(path));
        case RectShape(
          :final x,
          :final y,
          :final width,
          :final height,
          :final rx,
        ):
          path.addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, width, height),
              Radius.circular(rx),
            ),
          );
        case CircleShape(:final cx, :final cy, :final r):
          path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
        case EllipseShape(:final cx, :final cy, :final rx, :final ry):
          path.addOval(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: rx * 2,
              height: ry * 2,
            ),
          );
      }
    }
    return path;
  }
}

/// Feeds the commands of path_parsing into a Flutter [Path].
class _PathWriter extends PathProxy {
  _PathWriter(this.path);

  final Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}
