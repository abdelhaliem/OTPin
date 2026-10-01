import 'package:flutter/material.dart';

/// Shared default values used across OTPin styles.
abstract final class OTPinConstants {
  /// Default number of OTP digits.
  static const int defaultLength = 4;

  /// Default field size (width and height).
  static const double defaultFieldSize = 64.0;

  /// Default border radius for digit fields.
  static const double defaultBorderRadius = 16.0;

  /// Default border width.
  static const double defaultBorderWidth = 2.0;

  /// Default cursor width.
  static const double defaultCursorWidth = 2.0;

  /// Default cursor height ratio relative to field size.
  static const double defaultCursorHeightRatio = 0.4;

  /// Default digit font size.
  static const double defaultDigitFontSize = 24.0;

  /// Default spacing between fields in the row layout.
  static const double defaultFieldSpacing = 12.0;

  /// Default orbit radius for the verifying animation.
  static const double defaultOrbitRadius = 80.0;

  /// Default glow blur radius.
  static const double defaultGlowBlurRadius = 12.0;

  /// Default glow spread radius.
  static const double defaultGlowSpreadRadius = 2.0;

  /// Default digit text style.
  static const TextStyle defaultDigitTextStyle = TextStyle(
    fontSize: defaultDigitFontSize,
    fontWeight: FontWeight.w600,
    color: Color(0xFFECEFF1),
  );
}
