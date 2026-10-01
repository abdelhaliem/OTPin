/// OTPin — A customizable OTP input package with multiple visual
/// styles and rich animations.
///
/// The package uses the Strategy Pattern to decouple visual styles
/// from input logic, making it trivial to add new styles without
/// modifying existing code.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:otpin/otpin.dart';
///
/// OTPin(
///   length: 4,
///   style: OrbitalStyle(),
///   onCompleted: (code) async {
///     return await verifyOTP(code);
///   },
/// )
/// ```
library;

// Core.
export 'src/core/otpin_controller.dart';
export 'src/core/otpin_state.dart';
export 'src/core/otpin_widget.dart';

// Style interface.
export 'src/styles/otpin_style.dart';

// Orbital style.
export 'src/styles/orbital/orbital_style.dart';
export 'src/styles/orbital/orbital_style_config.dart';

// Cascade style.
export 'src/styles/cascade/cascade_style.dart';
export 'src/styles/cascade/cascade_style_config.dart';
