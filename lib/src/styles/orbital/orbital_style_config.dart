import 'package:flutter/material.dart';

import '../../utils/otpin_constants.dart';

/// Configuration for the [OrbitalStyle] OTP visual style.
///
/// Every visual property — colors, sizes, durations, and radii —
/// can be customized through this config. Sensible defaults are
/// provided so that zero-config usage looks great out of the box.
///
/// ```dart
/// OrbitalStyleConfig(
///   focusedBorderColor: Colors.cyan,
///   successColor: Colors.tealAccent,
///   fieldBorderRadius: 20.0,
/// )
/// ```
class OrbitalStyleConfig {
  /// Creates an [OrbitalStyleConfig] with customizable properties.
  const OrbitalStyleConfig({
    // ─── Colors ───
    this.focusedBorderColor = const Color(0xFF3B82F6),
    this.focusedGlowColor = const Color(0x663B82F6),
    this.filledBorderColor = const Color(0xFF2563EB),
    this.emptyBorderColor = const Color(0xFF25334D),
    this.fieldBackgroundColor = const Color(0xFF141C2E),
    this.cursorColor = const Color(0xFF60A5FA),
    this.successColor = const Color(0xFF00E676),
    this.successGlowColor = const Color(0x6600E676),
    this.errorColor = const Color(0xFFFF5252),
    this.errorGlowColor = const Color(0x66FF5252),
    this.orbitGuideColor = const Color(0xFF1E2B45),
    // ─── Success Display ───
    this.successIcon = Icons.check_rounded,
    this.successIconColor = Colors.white,
    this.successIconSize,
    this.successChild,
    // ─── Sizing ───
    this.fieldSize = OTPinConstants.defaultFieldSize,
    this.fieldBorderRadius = OTPinConstants.defaultBorderRadius,
    this.fieldBorderWidth = OTPinConstants.defaultBorderWidth,
    this.fieldSpacing = OTPinConstants.defaultFieldSpacing,
    this.orbitRadius = OTPinConstants.defaultOrbitRadius,
    this.orbitFieldScale = 0.7,
    // ─── Text ───
    this.digitTextStyle = OTPinConstants.defaultDigitTextStyle,
    // ─── Durations ───
    this.cursorBlinkDuration = const Duration(milliseconds: 500),
    this.digitEntryDuration = const Duration(milliseconds: 300),
    this.focusTransitionDuration = const Duration(
      milliseconds: 200,
    ),
    this.emptyPulseDuration = const Duration(milliseconds: 2000),
    this.orbitTransitionDuration = const Duration(milliseconds: 600),
    this.orbitRevolutionDuration = const Duration(
      milliseconds: 2500,
    ),
    this.successColorDuration = const Duration(milliseconds: 400),
    this.successConvergeDuration = const Duration(milliseconds: 600),
    this.successCircleDuration = const Duration(milliseconds: 300),
    this.errorShakeDuration = const Duration(milliseconds: 500),
    this.errorResetDuration = const Duration(milliseconds: 300),
  });

  // ─── Colors ───

  /// Border color of the currently focused field.
  final Color focusedBorderColor;

  /// Glow shadow color of the focused field.
  final Color focusedGlowColor;

  /// Border color of a field that has been filled.
  final Color filledBorderColor;

  /// Border color of an empty, unfocused field.
  final Color emptyBorderColor;

  /// Background fill color of each digit field.
  final Color fieldBackgroundColor;

  /// Color of the blinking cursor.
  final Color cursorColor;

  /// Border and glow color used in the success state.
  final Color successColor;

  /// Glow shadow color for the success state.
  final Color successGlowColor;

  /// Border and glow color used in the error state.
  final Color errorColor;

  /// Glow shadow color for the error state.
  final Color errorGlowColor;

  /// Color of the subtle solid guide ring behind the orbit.
  final Color orbitGuideColor;

  // ─── Success Display ───

  /// Icon to display in the center of the success circle.
  /// Defaults to [Icons.check_rounded].
  final IconData? successIcon;

  /// Color of the success icon. Defaults to [Colors.white].
  final Color? successIconColor;

  /// Size of the success icon. Defaults to [fieldSize] * 0.55.
  final double? successIconSize;

  /// Optional custom child widget to display in the success circle instead of [successIcon].
  final Widget? successChild;

  // ─── Sizing ───

  /// Width and height of each digit input field.
  final double fieldSize;

  /// Corner radius of each digit field.
  final double fieldBorderRadius;

  /// Border thickness of each field.
  final double fieldBorderWidth;

  /// Horizontal spacing between fields in the row layout.
  final double fieldSpacing;

  /// Radius of the circular orbit during the verifying phase.
  final double orbitRadius;

  /// Scale factor applied to fields during the orbit phase.
  final double orbitFieldScale;

  // ─── Text ───

  /// Text style for the digit characters.
  final TextStyle digitTextStyle;

  // ─── Durations ───

  /// Duration of one cursor blink cycle (on + off).
  final Duration cursorBlinkDuration;

  /// Duration of the scale-in animation for a newly entered digit.
  final Duration digitEntryDuration;

  /// Duration of the focus glow transition between fields.
  final Duration focusTransitionDuration;

  /// Duration of one full empty-state pulse cycle.
  final Duration emptyPulseDuration;

  /// Duration of the transition from row layout to orbit layout.
  final Duration orbitTransitionDuration;

  /// Duration of one full orbit revolution.
  final Duration orbitRevolutionDuration;

  /// Duration of the color transition to success green.
  final Duration successColorDuration;

  /// Duration of the convergence animation to center.
  final Duration successConvergeDuration;

  /// Duration of the final success circle reveal.
  final Duration successCircleDuration;

  /// Duration of the horizontal shake animation on error.
  final Duration errorShakeDuration;

  /// Duration of the reset animation after an error.
  final Duration errorResetDuration;

  /// Creates a copy with the given fields replaced.
  OrbitalStyleConfig copyWith({
    Color? focusedBorderColor,
    Color? focusedGlowColor,
    Color? filledBorderColor,
    Color? emptyBorderColor,
    Color? fieldBackgroundColor,
    Color? cursorColor,
    Color? successColor,
    Color? successGlowColor,
    Color? errorColor,
    Color? errorGlowColor,
    Color? orbitGuideColor,
    IconData? successIcon,
    Color? successIconColor,
    double? successIconSize,
    Widget? successChild,
    double? fieldSize,
    double? fieldBorderRadius,
    double? fieldBorderWidth,
    double? fieldSpacing,
    double? orbitRadius,
    double? orbitFieldScale,
    TextStyle? digitTextStyle,
    Duration? cursorBlinkDuration,
    Duration? digitEntryDuration,
    Duration? focusTransitionDuration,
    Duration? emptyPulseDuration,
    Duration? orbitTransitionDuration,
    Duration? orbitRevolutionDuration,
    Duration? successColorDuration,
    Duration? successConvergeDuration,
    Duration? successCircleDuration,
    Duration? errorShakeDuration,
    Duration? errorResetDuration,
  }) {
    return OrbitalStyleConfig(
      focusedBorderColor:
          focusedBorderColor ?? this.focusedBorderColor,
      focusedGlowColor: focusedGlowColor ?? this.focusedGlowColor,
      filledBorderColor:
          filledBorderColor ?? this.filledBorderColor,
      emptyBorderColor: emptyBorderColor ?? this.emptyBorderColor,
      fieldBackgroundColor:
          fieldBackgroundColor ?? this.fieldBackgroundColor,
      cursorColor: cursorColor ?? this.cursorColor,
      successColor: successColor ?? this.successColor,
      successGlowColor: successGlowColor ?? this.successGlowColor,
      errorColor: errorColor ?? this.errorColor,
      errorGlowColor: errorGlowColor ?? this.errorGlowColor,
      orbitGuideColor: orbitGuideColor ?? this.orbitGuideColor,
      successIcon: successIcon ?? this.successIcon,
      successIconColor: successIconColor ?? this.successIconColor,
      successIconSize: successIconSize ?? this.successIconSize,
      successChild: successChild ?? this.successChild,
      fieldSize: fieldSize ?? this.fieldSize,
      fieldBorderRadius:
          fieldBorderRadius ?? this.fieldBorderRadius,
      fieldBorderWidth: fieldBorderWidth ?? this.fieldBorderWidth,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      orbitRadius: orbitRadius ?? this.orbitRadius,
      orbitFieldScale: orbitFieldScale ?? this.orbitFieldScale,
      digitTextStyle: digitTextStyle ?? this.digitTextStyle,
      cursorBlinkDuration:
          cursorBlinkDuration ?? this.cursorBlinkDuration,
      digitEntryDuration:
          digitEntryDuration ?? this.digitEntryDuration,
      focusTransitionDuration:
          focusTransitionDuration ?? this.focusTransitionDuration,
      emptyPulseDuration:
          emptyPulseDuration ?? this.emptyPulseDuration,
      orbitTransitionDuration:
          orbitTransitionDuration ?? this.orbitTransitionDuration,
      orbitRevolutionDuration:
          orbitRevolutionDuration ?? this.orbitRevolutionDuration,
      successColorDuration:
          successColorDuration ?? this.successColorDuration,
      successConvergeDuration:
          successConvergeDuration ?? this.successConvergeDuration,
      successCircleDuration:
          successCircleDuration ?? this.successCircleDuration,
      errorShakeDuration:
          errorShakeDuration ?? this.errorShakeDuration,
      errorResetDuration:
          errorResetDuration ?? this.errorResetDuration,
    );
  }
}
