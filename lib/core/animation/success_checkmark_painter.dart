import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class SuccessCheckmarkPainter extends CustomPainter {
  SuccessCheckmarkPainter({required this.progress});

  final double progress; // 0.0 to 1.0

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 4;

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = OriginColors.goldDark;

    // First half of progress: draw circle
    final circleProgress = (progress / 0.55).clamp(0.0, 1.0);
    if (circleProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * circleProgress,
        false,
        circlePaint,
      );
    }

    // Second half: draw checkmark
    final checkProgress = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = OriginColors.goldDark;

      final checkPath = Path();
      final p1 = Offset(center.dx - radius * 0.42, center.dy + radius * 0.02);
      final p2 = Offset(center.dx - radius * 0.1, center.dy + radius * 0.35);
      final p3 = Offset(center.dx + radius * 0.46, center.dy - radius * 0.3);

      checkPath.moveTo(p1.dx, p1.dy);
      checkPath.lineTo(p2.dx, p2.dy);
      checkPath.lineTo(p3.dx, p3.dy);

      for (final metric in checkPath.computeMetrics()) {
        final extract = metric.extractPath(0.0, metric.length * checkProgress);
        canvas.drawPath(extract, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(SuccessCheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
