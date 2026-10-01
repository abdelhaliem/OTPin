import 'package:flutter/material.dart';

import 'orbital_style_config.dart';

/// A single digit input field for the Orbital style.
///
/// Renders a rounded-square box that can display a digit, a
/// blinking cursor, or an empty state — depending on the
/// current properties.
class OrbitalInputField extends StatelessWidget {
  /// Creates an orbital digit field.
  const OrbitalInputField({
    super.key,
    required this.config,
    required this.digit,
    required this.isFocused,
    required this.borderColor,
    required this.glowColor,
    required this.glowOpacity,
    required this.cursorOpacity,
    required this.digitScale,
    required this.scale,
  });

  /// Style configuration.
  final OrbitalStyleConfig config;

  /// The digit character to display, or empty string.
  final String digit;

  /// Whether this field is the currently focused field.
  final bool isFocused;

  /// The current border color.
  final Color borderColor;

  /// The current glow shadow color.
  final Color glowColor;

  /// Opacity of the glow effect (0.0 – 1.0).
  final double glowOpacity;

  /// Opacity of the cursor (0.0 or 1.0 for blink).
  final double cursorOpacity;

  /// Scale of the digit text (animates on entry).
  final double digitScale;

  /// Overall scale of the field (for orbit shrinking).
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = config.fieldSize * scale;

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedContainer(
        duration: config.focusTransitionDuration,
        decoration: BoxDecoration(
          color: config.fieldBackgroundColor,
          borderRadius: BorderRadius.circular(
            config.fieldBorderRadius * scale,
          ),
          border: Border.all(
            color: borderColor,
            width: config.fieldBorderWidth,
          ),
          boxShadow: glowOpacity > 0
              ? [
                  BoxShadow(
                    color: glowColor.withValues(alpha: glowOpacity),
                    blurRadius: 12.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: digit.isNotEmpty
              ? Transform.scale(
                  scale: digitScale,
                  child: Text(
                    digit,
                    style: config.digitTextStyle.copyWith(
                      fontSize:
                          (config.digitTextStyle.fontSize ?? 24) *
                          scale,
                    ),
                  ),
                )
              : _buildCursor(size),
        ),
      ),
    );
  }

  Widget _buildCursor(double fieldSize) {
    if (!isFocused || cursorOpacity <= 0) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: cursorOpacity,
      child: Container(
        width: 2,
        height: fieldSize * 0.4,
        decoration: BoxDecoration(
          color: config.cursorColor,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
