import 'package:flutter/material.dart';
import '../../app/theme.dart';

class LotusPainter extends CustomPainter {
  LotusPainter({
    required this.progress,
    this.color = OriginColors.goldDark,
    this.strokeWidth = 2.0,
  });

  final double progress; // 0.0 to 1.0
  final Color color;
  final double strokeWidth;

  static Path buildLotusPath(Size size) {
    final path = Path();
    final sx = size.width / 100.0;
    final sy = size.height / 100.0;

    // Center petal: M50 18C40 34 40 52 50 66 60 52 60 34 50 18Z
    path.moveTo(50 * sx, 18 * sy);
    path.cubicTo(40 * sx, 34 * sy, 40 * sx, 52 * sy, 50 * sx, 66 * sy);
    path.cubicTo(60 * sx, 52 * sy, 60 * sx, 34 * sy, 50 * sx, 18 * sy);
    path.close();

    // Inner left petal: M50 66C32 62 20 48 18 30 34 34 46 48 50 66Z
    path.moveTo(50 * sx, 66 * sy);
    path.cubicTo(32 * sx, 62 * sy, 20 * sx, 48 * sy, 18 * sx, 30 * sy);
    path.cubicTo(34 * sx, 34 * sy, 46 * sx, 48 * sy, 50 * sx, 66 * sy);
    path.close();

    // Inner right petal: M50 66C68 62 80 48 82 30 66 34 54 48 50 66Z
    path.moveTo(50 * sx, 66 * sy);
    path.cubicTo(68 * sx, 62 * sy, 80 * sx, 48 * sy, 82 * sx, 30 * sy);
    path.cubicTo(66 * sx, 34 * sy, 54 * sx, 48 * sy, 50 * sx, 66 * sy);
    path.close();

    // Outer left petal: M50 66C28 70 14 62 8 50 26 48 42 54 50 66Z
    path.moveTo(50 * sx, 66 * sy);
    path.cubicTo(28 * sx, 70 * sy, 14 * sx, 62 * sy, 8 * sx, 50 * sy);
    path.cubicTo(26 * sx, 48 * sy, 42 * sx, 54 * sy, 50 * sx, 66 * sy);
    path.close();

    // Outer right petal: M50 66C72 70 86 62 92 50 74 48 58 54 50 66Z
    path.moveTo(50 * sx, 66 * sy);
    path.cubicTo(72 * sx, 70 * sy, 86 * sx, 62 * sy, 92 * sx, 50 * sy);
    path.cubicTo(74 * sx, 48 * sy, 58 * sx, 54 * sy, 50 * sx, 66 * sy);
    path.close();

    // Base bar: M30 80H70
    path.moveTo(30 * sx, 80 * sy);
    path.lineTo(70 * sx, 80 * sy);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    final path = buildLotusPath(size);

    if (progress >= 0.999) {
      canvas.drawPath(path, paint);
      return;
    }

    for (final metric in path.computeMetrics()) {
      final extractLength = metric.length * progress.clamp(0.0, 1.0);
      final segment = metric.extractPath(0.0, extractLength);
      canvas.drawPath(segment, paint);
    }
  }

  @override
  bool shouldRepaint(LotusPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
