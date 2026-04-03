import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  double radius;
  Color color;
  double opacity;
  double dy;

  Particle({
    required this.position,
    required this.radius,
    required this.color,
    this.opacity = 0.85,
    this.dy = -1.0,
  });

  factory Particle.random(Size bounds, Color color) {
    final rng = Random();
    return Particle(
      position: Offset(
        30 + rng.nextDouble() * (bounds.width - 60),
        bounds.height * 0.5 + rng.nextDouble() * 80,
      ),
      radius: 3 + rng.nextDouble() * 5,
      color: color,
      dy: -(0.8 + rng.nextDouble() * 1.4),
    );
  }

  void update() {
    position = Offset(position.dx, position.dy + dy);
    opacity = (opacity - 0.018).clamp(0, 1);
  }

  bool get isDead => opacity <= 0;
}
