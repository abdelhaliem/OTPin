/// Represents the visual state of the OTP input widget.
///
/// Each state drives a distinct set of animations and visual
/// treatments in the active [OTPinStyle].
enum OTPinState {
  /// No digits entered yet. Fields show an ambient pulse animation.
  empty,

  /// The user is actively entering digits.
  typing,

  /// All digits have been entered and the code is being verified.
  verifying,

  /// Verification succeeded.
  success,

  /// Verification failed.
  error,
}
