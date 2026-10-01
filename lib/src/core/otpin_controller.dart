import 'package:flutter/material.dart';

import 'otpin_state.dart';

/// Controls the input logic, digit state, and lifecycle of an
/// [OTPin] widget.
///
/// The controller exposes [ValueNotifier]-based observables so that
/// both the composing widget and the active style can listen for
/// changes without tight coupling.
///
/// ```dart
/// final controller = OTPinController(length: 4);
/// controller.addDigit('7');
/// controller.removeLastDigit();
/// controller.clear();
/// ```
class OTPinController extends ChangeNotifier {
  /// Creates a controller for the given OTP [length].
  OTPinController({required this.length})
      : _digits = List<String>.filled(length, ''),
        _state = OTPinState.empty,
        _focusedIndex = 0;

  /// Number of OTP digits expected.
  final int length;

  /// Internal digit storage.
  final List<String> _digits;

  /// Current visual state.
  OTPinState _state;

  /// Index of the currently focused field.
  int _focusedIndex;

  // --------------- Public Getters ---------------

  /// An unmodifiable view of the current digits.
  List<String> get digits => List.unmodifiable(_digits);

  /// The current visual state of the OTP widget.
  OTPinState get state => _state;

  /// The index of the currently focused input field.
  int get focusedIndex => _focusedIndex;

  /// Whether all digit slots have been filled.
  bool get isFilled => _digits.every((d) => d.isNotEmpty);

  /// The current OTP string (may be partial).
  String get text => _digits.join();

  // --------------- Public Mutators ---------------

  /// Appends a single [digit] character to the next empty slot.
  ///
  /// If the code is already fully entered this is a no-op.
  void addDigit(String digit) {
    if (digit.length != 1) return;
    if (_state == OTPinState.verifying ||
        _state == OTPinState.success) {
      return;
    }

    final index = _digits.indexWhere((d) => d.isEmpty);
    if (index == -1) return;

    _digits[index] = digit;
    _focusedIndex = (index + 1).clamp(0, length - 1);

    if (_state == OTPinState.empty || _state == OTPinState.error) {
      _state = OTPinState.typing;
    }
    notifyListeners();
  }

  /// Removes the last entered digit, moving focus backward.
  void removeLastDigit() {
    if (_state == OTPinState.verifying ||
        _state == OTPinState.success) {
      return;
    }

    // Find the last filled index.
    int target = -1;
    for (int i = length - 1; i >= 0; i--) {
      if (_digits[i].isNotEmpty) {
        target = i;
        break;
      }
    }
    if (target == -1) return;

    _digits[target] = '';
    _focusedIndex = target;

    if (_digits.every((d) => d.isEmpty)) {
      _state = OTPinState.empty;
    }
    notifyListeners();
  }

  /// Replaces all digits at once (e.g. from clipboard paste).
  void setText(String value) {
    if (_state == OTPinState.verifying ||
        _state == OTPinState.success) {
      return;
    }

    final chars = value.split('');
    for (int i = 0; i < length; i++) {
      _digits[i] = i < chars.length ? chars[i] : '';
    }
    _focusedIndex = chars.length.clamp(0, length - 1);
    _state = isFilled ? OTPinState.typing : OTPinState.empty;
    notifyListeners();
  }

  /// Clears all digits and resets to [OTPinState.empty].
  void clear() {
    for (int i = 0; i < length; i++) {
      _digits[i] = '';
    }
    _focusedIndex = 0;
    _state = OTPinState.empty;
    notifyListeners();
  }

  /// Transitions to the [OTPinState.verifying] state.
  void startVerifying() {
    _state = OTPinState.verifying;
    notifyListeners();
  }

  /// Transitions to [OTPinState.success].
  void triggerSuccess() {
    _state = OTPinState.success;
    notifyListeners();
  }

  /// Transitions to [OTPinState.error], which will animate
  /// and then call [clear] automatically after the animation
  /// completes.
  void triggerError() {
    _state = OTPinState.error;
    notifyListeners();
  }

  /// Called by the style after the error animation finishes
  /// to reset the widget for another attempt.
  void resetAfterError() {
    clear();
  }
}
