import 'package:flutter/material.dart';

/// Paints a high-tech glowing laser shimmer beam across the OTP fields
/// during the verification cascading wave.
class CascadeShimmerPainter extends CustomPainter {
  /// Creates the shimmer painter.
  CascadeShimmerPainter({
    required this.progress,
    required this.beamColor,
    required this.opacity,
  });

  /// Current progress of the sweep (0.0 to 1.0).
  final double progress;

  /// Color of the luminous beam.
  final Color beamColor;

  /// Opacity multiplier.
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    final beamWidth = size.width * 0.35;
    final beamStart = -beamWidth + (size.width + beamWidth * 2) * progress;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        beamColor.withValues(alpha: 0.0),
        beamColor.withValues(alpha: 0.4 * opacity),
        beamColor.withValues(alpha: 0.8 * opacity),
        beamColor.withValues(alpha: 0.4 * opacity),
        beamColor.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(beamStart, 0, beamWidth, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw top laser beam along the upper boundary of the row.
    canvas.drawLine(
      Offset(0, 0),
      Offset(size.width, 0),
      paint,
    );

    // Draw bottom laser beam along the lower boundary.
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CascadeShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.beamColor != beamColor ||
        oldDelegate.opacity != opacity;
  }
}
