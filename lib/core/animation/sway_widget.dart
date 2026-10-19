import 'package:flutter/material.dart';
import '../utils/breakpoints.dart';

class SwayingObject extends StatefulWidget {
  const SwayingObject({
    super.key,
    required this.child,
    this.maxAngle = 0.38,
  });

  final Widget child;
  final double maxAngle;

  @override
  State<SwayingObject> createState() => _SwayingObjectState();
}

class _SwayingObjectState extends State<SwayingObject>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isReducedMotion(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final angle = Tween(
          begin: -widget.maxAngle,
          end: widget.maxAngle,
        ).transform(Curves.easeInOut.transform(_controller.value));

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: child,
        );
      },
    );
  }
}
