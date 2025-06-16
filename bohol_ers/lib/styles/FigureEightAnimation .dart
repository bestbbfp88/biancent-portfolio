import 'package:flutter/material.dart';
import 'dart:math';

class FigureEightAnimation extends StatefulWidget {
  const FigureEightAnimation({super.key});

  @override
  State<FigureEightAnimation> createState() => _FigureEightAnimationState();
}

class _FigureEightAnimationState extends State<FigureEightAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _calculateFigureEight(double t) {
    final double x = 50 * sin(t);            // Horizontal swing
    final double y = 50 * sin(2 * t);        // Vertical swing (twice the frequency)
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final t = _controller.value * 2 * pi; // Full rotation range
        final offset = _calculateFigureEight(t);

        return Transform.translate(
          offset: offset,
          child: child,
        );
      },
      child: Icon(Icons.phone_android, size: 80, color: Colors.teal),
    );
  }
}
