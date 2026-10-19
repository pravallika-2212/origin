import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class GoldParticle {
  GoldParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  double x; // 0.0 to 1.0
  double y; // 0.0 to 1.0
  final double radius;
  final double speed;
  double phase;
}

class DustParticlesWidget extends StatefulWidget {
  const DustParticlesWidget({super.key, this.particleCount = 70});

  final int particleCount;

  @override
  State<DustParticlesWidget> createState() => _DustParticlesWidgetState();
}

class _DustParticlesWidgetState extends State<DustParticlesWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<GoldParticle> _particles;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.particleCount, (_) {
      return GoldParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 1.6 + 0.4,
        speed: _random.nextDouble() * 0.0006 + 0.0002,
        phase: _random.nextDouble() * 6.28,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particles
        for (final p in _particles) {
          p.phase += 0.03;
          p.y -= p.speed;
          if (p.y < 0.0) {
            p.y = 1.0;
            p.x = _random.nextDouble();
          }
        }
        return CustomPaint(
          size: Size.infinite,
          painter: DustPainter(particles: _particles),
        );
      },
    );
  }
}

class DustPainter extends CustomPainter {
  DustPainter({required this.particles});

  final List<GoldParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = OriginColors.gold;

    for (final p in particles) {
      final alpha = (0.2 + 0.4 * sin(p.phase).abs()).clamp(0.0, 1.0);
      paint.color = OriginColors.gold.withValues(alpha: alpha);
      final center = Offset(p.x * size.width, p.y * size.height);
      canvas.drawCircle(center, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
