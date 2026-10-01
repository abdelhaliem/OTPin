import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/otpin_controller.dart';
import '../../core/otpin_state.dart';
import '../otpin_style.dart';
import 'orbital_input_field.dart';
import 'orbital_orbit_painter.dart';
import 'orbital_style_config.dart';

/// The Orbital OTP style — an animated OTP input where digit
/// fields orbit in a circle during verification, then converge
/// for success or shake for error.
///
/// This is the first built-in style shipped with OTPin, inspired
/// by the reference video's spectacular animation sequence.
class OrbitalStyle extends OTPinStyle {
  /// Creates an orbital style with an optional [config].
  OrbitalStyle({OrbitalStyleConfig? config})
      : config = config ?? const OrbitalStyleConfig();

  /// Configuration for colors, sizes, and durations.
  final OrbitalStyleConfig config;

  @override
  Widget build(
    BuildContext context, {
    required OTPinController controller,
    required FocusNode focusNode,
  }) {
    return _OrbitalStyleWidget(
      config: config,
      controller: controller,
      focusNode: focusNode,
    );
  }
}

class _OrbitalStyleWidget extends StatefulWidget {
  const _OrbitalStyleWidget({
    required this.config,
    required this.controller,
    required this.focusNode,
  });

  final OrbitalStyleConfig config;
  final OTPinController controller;
  final FocusNode focusNode;

  @override
  State<_OrbitalStyleWidget> createState() =>
      _OrbitalStyleWidgetState();
}

class _OrbitalStyleWidgetState extends State<_OrbitalStyleWidget>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───

  late AnimationController _cursorController;
  late AnimationController _emptyPulseController;
  late AnimationController _orbitTransitionController;
  late AnimationController _orbitRotationController;
  late AnimationController _successColorController;
  late AnimationController _successConvergeController;
  late AnimationController _successCircleController;
  late AnimationController _errorShakeController;
  late AnimationController _errorResetController;

  // ─── Digit entry animations (one per field) ───
  late List<AnimationController> _digitEntryControllers;

  // ─── Derived animations ───
  late Animation<double> _cursorAnimation;
  late Animation<double> _emptyPulseAnimation;
  late Animation<double> _orbitTransitionAnimation;
  late Animation<double> _successConvergeAnimation;
  late Animation<double> _successCircleAnimation;
  late Animation<double> _errorShakeAnimation;

  OTPinState _previousState = OTPinState.empty;
  List<String> _previousDigits = [];

  OrbitalStyleConfig get _config => widget.config;
  OTPinController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _ctrl.addListener(_onControllerChanged);
    _previousDigits = List.from(_ctrl.digits);

    // Start ambient animations.
    _cursorController.repeat(reverse: true);
    _emptyPulseController.repeat(reverse: true);
  }

  void _initAnimations() {
    // Cursor blink.
    _cursorController = AnimationController(
      vsync: this,
      duration: _config.cursorBlinkDuration,
    );
    _cursorAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_cursorController);

    // Empty pulse.
    _emptyPulseController = AnimationController(
      vsync: this,
      duration: _config.emptyPulseDuration,
    );
    _emptyPulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(
      CurvedAnimation(
        parent: _emptyPulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Digit entry (per field).
    _digitEntryControllers = List.generate(
      _ctrl.length,
      (_) => AnimationController(
        vsync: this,
        duration: _config.digitEntryDuration,
      ),
    );

    // Orbit transition (row → circle).
    _orbitTransitionController = AnimationController(
      vsync: this,
      duration: _config.orbitTransitionDuration,
    );
    _orbitTransitionAnimation = CurvedAnimation(
      parent: _orbitTransitionController,
      curve: Curves.easeInOutCubic,
    );

    // Orbit continuous rotation.
    _orbitRotationController = AnimationController(
      vsync: this,
      duration: _config.orbitRevolutionDuration,
    );

    // Success color transition.
    _successColorController = AnimationController(
      vsync: this,
      duration: _config.successColorDuration,
    );

    // Success convergence.
    _successConvergeController = AnimationController(
      vsync: this,
      duration: _config.successConvergeDuration,
    );
    _successConvergeAnimation = CurvedAnimation(
      parent: _successConvergeController,
      curve: Curves.easeInBack,
    );

    // Success circle reveal.
    _successCircleController = AnimationController(
      vsync: this,
      duration: _config.successCircleDuration,
    );
    _successCircleAnimation = CurvedAnimation(
      parent: _successCircleController,
      curve: Curves.elasticOut,
    );

    // Error shake.
    _errorShakeController = AnimationController(
      vsync: this,
      duration: _config.errorShakeDuration,
    );
    _errorShakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 8),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 8, end: -8),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -8, end: 6),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 6, end: -6),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -6, end: 3),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 3, end: -3),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -3, end: 0),
        weight: 1,
      ),
    ]).animate(_errorShakeController);

    // Error reset.
    _errorResetController = AnimationController(
      vsync: this,
      duration: _config.errorResetDuration,
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _cursorController.dispose();
    _emptyPulseController.dispose();
    _orbitTransitionController.dispose();
    _orbitRotationController.dispose();
    _successColorController.dispose();
    _successConvergeController.dispose();
    _successCircleController.dispose();
    _errorShakeController.dispose();
    _errorResetController.dispose();
    for (final c in _digitEntryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── State Change Handler ───

  void _onControllerChanged() {
    final newState = _ctrl.state;
    final newDigits = _ctrl.digits;

    // Detect new digit entries for scale-in animation.
    for (int i = 0; i < _ctrl.length; i++) {
      if (i < _previousDigits.length &&
          _previousDigits[i].isEmpty &&
          newDigits[i].isNotEmpty) {
        _digitEntryControllers[i].forward(from: 0);
      } else if (newDigits[i].isEmpty) {
        _digitEntryControllers[i].reset();
      }
    }
    _previousDigits = List.from(newDigits);

    // Handle state transitions.
    if (newState != _previousState) {
      _handleStateTransition(_previousState, newState);
      _previousState = newState;
    }

    setState(() {});
  }

  void _handleStateTransition(
    OTPinState from,
    OTPinState to,
  ) {
    switch (to) {
      case OTPinState.empty:
        _emptyPulseController.repeat(reverse: true);
        _orbitTransitionController.reset();
        _orbitRotationController.reset();
        _successColorController.reset();
        _successConvergeController.reset();
        _successCircleController.reset();
      case OTPinState.typing:
        _emptyPulseController.stop();
        // Reset orbit & success if coming from error or reset.
        _orbitTransitionController.reset();
        _orbitRotationController.reset();
        _successColorController.reset();
        _successConvergeController.reset();
        _successCircleController.reset();
      case OTPinState.verifying:
        _startVerifyingAnimation();
      case OTPinState.success:
        _startSuccessAnimation();
      case OTPinState.error:
        _startErrorAnimation();
    }
  }

  Future<void> _startVerifyingAnimation() async {
    await _orbitTransitionController.forward(from: 0);
    _orbitRotationController.repeat();
  }

  Future<void> _startSuccessAnimation() async {
    // Phase A: Color transition.
    await _successColorController.forward(from: 0);
    // Phase B: Convergence.
    await _successConvergeController.forward(from: 0);
    // Phase C: Circle reveal.
    _orbitRotationController.stop();
    await _successCircleController.forward(from: 0);
  }

  Future<void> _startErrorAnimation() async {
    // Phase A + B: Shake.
    await _errorShakeController.forward(from: 0);
    // Phase C: Reset.
    _errorResetController.forward(from: 0);
    await Future.delayed(_config.errorResetDuration);
    _errorShakeController.reset();
    _errorResetController.reset();

    // Reset orbit animations.
    _orbitTransitionController.reset();
    _orbitRotationController.stop();
    _orbitRotationController.reset();
    _successColorController.reset();

    _ctrl.resetAfterError();
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _cursorController,
          _emptyPulseController,
          _orbitTransitionController,
          _orbitRotationController,
          _successColorController,
          _successConvergeController,
          _successCircleController,
          _errorShakeController,
          _errorResetController,
          ..._digitEntryControllers,
        ]),
        builder: (context, _) {
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    final transitionProgress = _orbitTransitionAnimation.value;

    // Calculate the area needed.
    final orbitDiameter = _config.orbitRadius * 2 +
        _config.fieldSize * _config.orbitFieldScale;
    final rowWidth = _ctrl.length * _config.fieldSize +
        (_ctrl.length - 1) * _config.fieldSpacing;
    final contentWidth =
        math.max(orbitDiameter, rowWidth) + 40;
    final contentHeight =
        math.max(orbitDiameter, _config.fieldSize) + 40;

    Widget content = SizedBox(
      width: contentWidth,
      height: contentHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Orbit rings (painted behind the fields).
          if (transitionProgress > 0)
            Positioned.fill(
              child: CustomPaint(
                painter: OrbitalOrbitPainter(
                  config: _config,
                  orbitRadius: _currentOrbitRadius,
                  dotRotation: _dotRotation,
                  borderColor: _currentBorderColor,
                  opacity: transitionProgress,
                ),
              ),
            ),

          // Digit fields.
          ..._buildFields(
            contentWidth,
            contentHeight,
            transitionProgress,
          ),

          // Success circle overlay.
          if (_successCircleController.isAnimating ||
              _successCircleController.isCompleted)
            Center(
              child: Transform.scale(
                scale: _successCircleAnimation.value,
                child: Container(
                  width: _config.fieldSize * 1.2,
                  height: _config.fieldSize * 1.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _config.successColor.withValues(alpha: 0.16),
                    border: Border.all(
                      color: _config.successColor,
                      width: _config.fieldBorderWidth + 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _config.successGlowColor,
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _config.successChild ??
                        (_config.successIcon != null
                            ? Icon(
                                _config.successIcon,
                                color: _config.successIconColor ??
                                    Colors.white,
                                size: _config.successIconSize ??
                                    (_config.fieldSize * 0.55),
                              )
                            : const SizedBox.shrink()),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Error shake wrapper.
    if (_ctrl.state == OTPinState.error &&
        _errorShakeController.isAnimating) {
      content = Transform.translate(
        offset: Offset(_errorShakeAnimation.value, 0),
        child: content,
      );
    }

    return content;
  }

  List<Widget> _buildFields(
    double containerWidth,
    double containerHeight,
    double transitionProgress,
  ) {
    final fields = <Widget>[];
    final centerX = containerWidth / 2;
    final centerY = containerHeight / 2;

    for (int i = 0; i < _ctrl.length; i++) {
      // Row position (centered).
      final totalRowWidth = _ctrl.length * _config.fieldSize +
          (_ctrl.length - 1) * _config.fieldSpacing;
      final rowStartX = centerX - totalRowWidth / 2;
      final rowX = rowStartX +
          i * (_config.fieldSize + _config.fieldSpacing) +
          _config.fieldSize / 2;
      final rowY = centerY;

      // Orbit position.
      final angle = _orbitAngleForIndex(i);
      final radius = _currentOrbitRadius;
      final orbitX = centerX + radius * math.cos(angle);
      final orbitY = centerY + radius * math.sin(angle);

      // Interpolate between row and orbit positions.
      final x = _lerpDouble(rowX, orbitX, transitionProgress);
      final y = _lerpDouble(rowY, orbitY, transitionProgress);

      // Scale.
      final scale = _lerpDouble(
        1.0,
        _config.orbitFieldScale,
        transitionProgress,
      );

      // Convergence (shrinks fields to center on success).
      final convergeScale = _successConvergeController.isAnimating ||
              _successConvergeController.isCompleted
          ? _lerpDouble(
              1.0,
              0.0,
              _successConvergeAnimation.value,
            )
          : 1.0;

      final finalScale = scale * convergeScale;
      if (finalScale <= 0.01) continue;

      // Border and glow colors.
      final borderColor = _borderColorForField(i);
      final glowColor = _glowColorForField(i);
      final glowOpacity = _glowOpacityForField(i);

      // Cursor.
      final isFocused = _ctrl.focusedIndex == i &&
          (_ctrl.state == OTPinState.empty ||
              _ctrl.state == OTPinState.typing);
      final cursorOpacity =
          isFocused ? _cursorAnimation.value : 0.0;

      // Digit scale.
      final digitScale = _ctrl.digits[i].isNotEmpty
          ? _digitEntryControllers[i].isCompleted
                ? 1.0
                : CurvedAnimation(
                    parent: _digitEntryControllers[i],
                    curve: Curves.elasticOut,
                  ).value
          : 0.0;

      fields.add(
        Positioned(
          left: x - (_config.fieldSize * finalScale) / 2,
          top: y - (_config.fieldSize * finalScale) / 2,
          child: OrbitalInputField(
            config: _config,
            digit: _ctrl.digits[i],
            isFocused: isFocused,
            borderColor: borderColor,
            glowColor: glowColor,
            glowOpacity: glowOpacity,
            cursorOpacity: cursorOpacity,
            digitScale: digitScale,
            scale: finalScale,
          ),
        ),
      );
    }

    return fields;
  }

  // ─── Orbit Calculations ───

  double _orbitAngleForIndex(int index) {
    final baseAngle = 2 * math.pi * index / _ctrl.length;
    // Start from top (-π/2) and add rotation.
    final rotationOffset =
        _orbitRotationController.value * 2 * math.pi;
    return baseAngle - math.pi / 2 + rotationOffset;
  }

  double get _currentOrbitRadius {
    if (_successConvergeController.isAnimating ||
        _successConvergeController.isCompleted) {
      return _config.orbitRadius *
          (1 - _successConvergeAnimation.value);
    }
    return _config.orbitRadius;
  }

  double get _dotRotation {
    // Dotted ring rotates slightly slower for parallax.
    return _orbitRotationController.value * 2 * math.pi * 0.8;
  }

  // ─── Color Calculations ───

  Color get _currentBorderColor {
    if (_ctrl.state == OTPinState.error) {
      return _config.errorColor;
    }
    if (_successColorController.isAnimating ||
        _successColorController.isCompleted) {
      return Color.lerp(
        _config.focusedBorderColor,
        _config.successColor,
        _successColorController.value,
      )!;
    }
    return _config.focusedBorderColor;
  }

  Color _borderColorForField(int index) {
    final state = _ctrl.state;

    switch (state) {
      case OTPinState.empty:
        // Pulsing empty border.
        return _config.emptyBorderColor.withValues(
          alpha: _emptyPulseAnimation.value,
        );

      case OTPinState.typing:
        if (_ctrl.focusedIndex == index &&
            _ctrl.digits[index].isEmpty) {
          return _config.focusedBorderColor;
        }
        if (_ctrl.digits[index].isNotEmpty) {
          return _config.filledBorderColor;
        }
        return _config.emptyBorderColor;

      case OTPinState.verifying:
        return _currentBorderColor;

      case OTPinState.success:
        return _currentBorderColor;

      case OTPinState.error:
        return _config.errorColor;
    }
  }

  Color _glowColorForField(int index) {
    final state = _ctrl.state;

    switch (state) {
      case OTPinState.empty:
        return _config.focusedGlowColor;
      case OTPinState.typing:
        return _config.focusedGlowColor;
      case OTPinState.verifying:
        return _currentBorderColor;
      case OTPinState.success:
        return _config.successGlowColor;
      case OTPinState.error:
        return _config.errorGlowColor;
    }
  }

  double _glowOpacityForField(int index) {
    final state = _ctrl.state;

    switch (state) {
      case OTPinState.empty:
        return _emptyPulseAnimation.value * 0.3;

      case OTPinState.typing:
        if (_ctrl.focusedIndex == index &&
            _ctrl.digits[index].isEmpty) {
          return 0.6;
        }
        return 0.0;

      case OTPinState.verifying:
      case OTPinState.success:
        return 0.5;

      case OTPinState.error:
        return 0.6;
    }
  }

  // ─── Helpers ───

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
