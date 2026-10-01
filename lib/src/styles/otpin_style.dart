import 'package:flutter/material.dart';

import '../core/otpin_controller.dart';

/// Abstract interface that every OTP visual style must implement.
///
/// The Strategy Pattern is used here so that different visual
/// representations (Orbital, Underline, Box, etc.) can be swapped
/// without changing the core logic or the public [OTPin] API.
///
/// Implementors receive the [OTPinController] and are responsible
/// for rendering the appropriate UI for every [OTPinState].
abstract class OTPinStyle {
  /// Builds the complete visual representation of the OTP input.
  ///
  /// The [controller] provides access to digits, focus index, and
  /// the current state. Implementations should listen to the
  /// controller (via [ListenableBuilder] or [AnimatedBuilder]) to
  /// react to state changes.
  ///
  /// [focusNode] is already attached to a hidden [TextField] that
  /// captures keyboard input. Styles should use it to request focus
  /// on tap.
  Widget build(
    BuildContext context, {
    required OTPinController controller,
    required FocusNode focusNode,
  });
}
