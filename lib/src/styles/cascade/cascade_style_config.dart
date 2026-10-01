import 'package:flutter/material.dart';

import '../../utils/otpin_constants.dart';

/// Configuration for the [CascadeStyle] OTP visual style.
///
/// Features customizable colors, sizes, wave heights, and animation
/// durations. Fully decoupled and self-contained with immutable [copyWith].
///
/// ```dart
/// CascadeStyleConfig(
///   focusedBorderColor: Colors.blueAccent,
///   waveHeight: 16.0,
///   fieldBorderRadius: 18.0,
/// )
/// ```
class CascadeStyleConfig {
  /// Creates a [CascadeStyleConfig] with customizable properties.
  const CascadeStyleConfig({
    // ─── Colors ───
    this.focusedBorderColor = const Color(0xFF3B82F6),
    this.focusedGlowColor = const Color(0x663B82F6),
    this.filledBorderColor = const Color(0xFF2563EB),
    this.emptyBorderColor = const Color(0xFF25334D),
    this.fieldBackgroundColor = const Color(0xFF141C2E),
    this.cursorColor = const Color(0xFF60A5FA),
    this.waveBeamColor = const Color(0xFF60A5FA),
    this.successColor = const Color(0xFF00E676),
    this.successGlowColor = const Color(0x6600E676),
    this.errorColor = const Color(0xFFFF5252),
    this.errorGlowColor = const Color(0x66FF5252),
    // ─── Success Display ───
    this.successIcon = Icons.check_rounded,
    this.successIconColor = Colors.white,
    this.successIconSize,
    this.successText = 'Verified',
    this.successTextStyle,
    // ─── Sizing ───
    this.fieldSize = OTPinConstants.defaultFieldSize,
    this.fieldBorderRadius = OTPinConstants.defaultBorderRadius,
    this.fieldBorderWidth = OTPinConstants.defaultBorderWidth,
    this.fieldSpacing = OTPinConstants.defaultFieldSpacing,
    this.waveHeight = 14.0,
    // ─── Text ───
    this.digitTextStyle = OTPinConstants.defaultDigitTextStyle,
    // ─── Durations ───
    this.cursorBlinkDuration = const Duration(milliseconds: 500),
    this.digitEntryDuration = const Duration(milliseconds: 250),
    this.waveCycleDuration = const Duration(milliseconds: 1200),
    this.morphDuration = const Duration(milliseconds: 500),
    this.successCheckDuration = const Duration(milliseconds: 400),
    this.errorShakeDuration = const Duration(milliseconds: 500),
    this.errorResetDuration = const Duration(milliseconds: 300),
  });

  // ─── Colors ───

  /// Border color of the currently focused field.
  final Color focusedBorderColor;

  /// Glow shadow color of the focused field.
  final Color focusedGlowColor;

  /// Border color of an entered digit field.
  final Color filledBorderColor;

  /// Border color of an empty, unfocused field.
  final Color emptyBorderColor;

  /// Background fill color of each digit field.
  final Color fieldBackgroundColor;

  /// Color of the blinking cursor.
  final Color cursorColor;

  /// Highlight shimmer color used during the cascading wave.
  final Color waveBeamColor;

  /// Border, glow, and accent color in the success state.
  final Color successColor;

  /// Glow shadow color for the success state.
  final Color successGlowColor;

  /// Border and glow color in the error state.
  final Color errorColor;

  /// Glow shadow color for the error state.
  final Color errorGlowColor;

  // ─── Success Display ───

  /// Icon displayed in the center of the merged success capsule.
  final IconData? successIcon;

  /// Color of the success icon.
  final Color? successIconColor;

  /// Size of the success icon. Defaults to [fieldSize] * 0.5.
  final double? successIconSize;

  /// Optional label displayed beside the checkmark upon success.
  final String? successText;

  /// Text style for the [successText].
  final TextStyle? successTextStyle;

  // ─── Sizing ───

  /// Width and height of each digit input field.
  final double fieldSize;

  /// Corner radius of each digit field.
  final double fieldBorderRadius;

  /// Border thickness of each field.
  final double fieldBorderWidth;

  /// Horizontal spacing between fields.
  final double fieldSpacing;

  /// Peak vertical oscillation distance during the verifying wave.
  final double waveHeight;

  // ─── Text ───

  /// Text style for the digit characters.
  final TextStyle digitTextStyle;

  // ─── Durations ───

  /// Duration of one cursor blink cycle.
  final Duration cursorBlinkDuration;

  /// Duration of digit entry pop-in animation.
  final Duration digitEntryDuration;

  /// Duration of one full sinusoidal wave cycle during verification.
  final Duration waveCycleDuration;

  /// Duration of the capsule merge/morph animation on success.
  final Duration morphDuration;

  /// Duration of the checkmark reveal inside the success capsule.
  final Duration successCheckDuration;

  /// Duration of the staggered domino shake on error.
  final Duration errorShakeDuration;

  /// Duration of the reset animation after error.
  final Duration errorResetDuration;

  /// Creates a copy with the given fields replaced.
  CascadeStyleConfig copyWith({
    Color? focusedBorderColor,
    Color? focusedGlowColor,
    Color? filledBorderColor,
    Color? emptyBorderColor,
    Color? fieldBackgroundColor,
    Color? cursorColor,
    Color? waveBeamColor,
    Color? successColor,
    Color? successGlowColor,
    Color? errorColor,
    Color? errorGlowColor,
    IconData? successIcon,
    Color? successIconColor,
    double? successIconSize,
    String? successText,
    TextStyle? successTextStyle,
    double? fieldSize,
    double? fieldBorderRadius,
    double? fieldBorderWidth,
    double? fieldSpacing,
    double? waveHeight,
    TextStyle? digitTextStyle,
    Duration? cursorBlinkDuration,
    Duration? digitEntryDuration,
    Duration? waveCycleDuration,
    Duration? morphDuration,
    Duration? successCheckDuration,
    Duration? errorShakeDuration,
    Duration? errorResetDuration,
  }) {
    return CascadeStyleConfig(
      focusedBorderColor:
          focusedBorderColor ?? this.focusedBorderColor,
      focusedGlowColor: focusedGlowColor ?? this.focusedGlowColor,
      filledBorderColor:
          filledBorderColor ?? this.filledBorderColor,
      emptyBorderColor: emptyBorderColor ?? this.emptyBorderColor,
      fieldBackgroundColor:
          fieldBackgroundColor ?? this.fieldBackgroundColor,
      cursorColor: cursorColor ?? this.cursorColor,
      waveBeamColor: waveBeamColor ?? this.waveBeamColor,
      successColor: successColor ?? this.successColor,
      successGlowColor: successGlowColor ?? this.successGlowColor,
      errorColor: errorColor ?? this.errorColor,
      errorGlowColor: errorGlowColor ?? this.errorGlowColor,
      successIcon: successIcon ?? this.successIcon,
      successIconColor: successIconColor ?? this.successIconColor,
      successIconSize: successIconSize ?? this.successIconSize,
      successText: successText ?? this.successText,
      successTextStyle: successTextStyle ?? this.successTextStyle,
      fieldSize: fieldSize ?? this.fieldSize,
      fieldBorderRadius:
          fieldBorderRadius ?? this.fieldBorderRadius,
      fieldBorderWidth: fieldBorderWidth ?? this.fieldBorderWidth,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      waveHeight: waveHeight ?? this.waveHeight,
      digitTextStyle: digitTextStyle ?? this.digitTextStyle,
      cursorBlinkDuration:
          cursorBlinkDuration ?? this.cursorBlinkDuration,
      digitEntryDuration:
          digitEntryDuration ?? this.digitEntryDuration,
      waveCycleDuration:
          waveCycleDuration ?? this.waveCycleDuration,
      morphDuration: morphDuration ?? this.morphDuration,
      successCheckDuration:
          successCheckDuration ?? this.successCheckDuration,
      errorShakeDuration:
          errorShakeDuration ?? this.errorShakeDuration,
      errorResetDuration:
          errorResetDuration ?? this.errorResetDuration,
    );
  }
}
