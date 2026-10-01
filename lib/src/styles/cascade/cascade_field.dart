import 'package:flutter/material.dart';

import 'cascade_style_config.dart';

/// An individual digit field for [CascadeStyle].
///
/// Features dynamic [borderRadius] (supporting capsule morphing),
/// drop-in digit animation, smooth glow shadows, and cursor blinking.
class CascadeField extends StatelessWidget {
  /// Creates a cascade digit field.
  const CascadeField({
    super.key,
    required this.config,
    required this.digit,
    required this.isFocused,
    required this.borderColor,
    required this.borderRadius,
    required this.glowColor,
    required this.glowOpacity,
    required this.cursorOpacity,
    required this.digitScale,
    required this.digitOffset,
    required this.digitOpacity,
    required this.scale,
    this.backgroundColor,
  });

  /// Style configuration.
  final CascadeStyleConfig config;

  /// Digit text to display, or empty string.
  final String digit;

  /// Whether this field has active focus.
  final bool isFocused;

  /// Border color.
  final Color borderColor;

  /// Custom border radius (morphs into capsule on success).
  final BorderRadius borderRadius;

  /// Glow shadow color.
  final Color glowColor;

  /// Glow opacity (0.0 to 1.0).
  final double glowOpacity;

  /// Cursor opacity for blinking.
  final double cursorOpacity;

  /// Scale of the digit text.
  final double digitScale;

  /// Vertical offset of the digit text during drop-in entry.
  final Offset digitOffset;

  /// Opacity of the digit text (fades out when morphing to success).
  final double digitOpacity;

  /// Overall scale of the box (for entry bump).
  final double scale;

  /// Optional background color override.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final size = config.fieldSize;

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor ?? config.fieldBackgroundColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: config.fieldBorderWidth,
            ),
            boxShadow: glowOpacity > 0.01
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: glowOpacity),
                      blurRadius: 14.0,
                      spreadRadius: 2.0,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: digit.isNotEmpty
                ? Opacity(
                    opacity: digitOpacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: digitOffset,
                      child: Transform.scale(
                        scale: digitScale,
                        child: Text(
                          digit,
                          style: config.digitTextStyle,
                        ),
                      ),
                    ),
                  )
                : _buildCursor(size),
          ),
        ),
      ),
    );
  }

  Widget _buildCursor(double size) {
    if (!isFocused || cursorOpacity <= 0) {
      return const SizedBox.shrink();
    }

    return Opacity(
      opacity: cursorOpacity,
      child: Container(
        width: 2.5,
        height: size * 0.42,
        decoration: BoxDecoration(
          color: config.cursorColor,
          borderRadius: BorderRadius.circular(1.5),
          boxShadow: [
            BoxShadow(
              color: config.cursorColor.withValues(alpha: 0.5),
              blurRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}
