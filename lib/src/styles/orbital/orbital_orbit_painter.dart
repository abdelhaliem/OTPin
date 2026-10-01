import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'orbital_style_config.dart';

/// Custom painter that draws the dotted orbit track and the
/// solid guide ring behind the orbiting digit fields.
class OrbitalOrbitPainter extends CustomPainter {
  /// Creates the orbit painter.
  OrbitalOrbitPainter({
    required this.config,
    required this.orbitRadius,
    required this.dotRotation,
    required this.borderColor,
    required this.opacity,
  });

  /// Style configuration.
  final OrbitalStyleConfig config;

  /// Current orbit radius (animates during convergence).
  final double orbitRadius;

  /// Current rotation angle of the dotted ring in radians.
  final double dotRotation;

  /// Current border/dot color (animates during success).
  final Color borderColor;

  /// Overall opacity of the rings (for fade-in / fade-out).
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Only draw rings if the orbit has not collapsed to center.
    if (orbitRadius > 4.0) {
      // ─── Solid guide ring ───
      final guidePaint = Paint()
        ..color = config.orbitGuideColor.withValues(
          alpha: 0.4 * opacity,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, orbitRadius, guidePaint);

      // ─── Dotted orbit ring ───
      final dotPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.8 * opacity)
        ..style = PaintingStyle.fill;

      const dotCount = 48;
      const dotRadius = 2.0;

      for (int i = 0; i < dotCount; i++) {
        final angle =
            dotRotation + (2 * math.pi * i / dotCount);
        final x = center.dx + orbitRadius * math.cos(angle);
        final y = center.dy + orbitRadius * math.sin(angle);
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OrbitalOrbitPainter oldDelegate) {
    return oldDelegate.orbitRadius != orbitRadius ||
        oldDelegate.dotRotation != dotRotation ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.opacity != opacity;
  }
}
