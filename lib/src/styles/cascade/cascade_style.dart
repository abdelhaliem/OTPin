import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/otpin_controller.dart';
import '../../core/otpin_state.dart';
import '../otpin_style.dart';
import 'cascade_field.dart';
import 'cascade_shimmer_painter.dart';
import 'cascade_style_config.dart';

/// The Cascade OTP style — an animated OTP input where digit fields
/// oscillate in an energetic sinusoidal wave during verification,
/// then smoothly morph and fuse together into a single unified
/// capsule badge on success, or perform a staggered domino shake on error.
///
/// Completely decoupled and architected using the Strategy Pattern.
class CascadeStyle extends OTPinStyle {
  /// Creates a cascade style with an optional [config].
  CascadeStyle({CascadeStyleConfig? config})
      : config = config ?? const CascadeStyleConfig();

  /// Configuration for colors, sizes, wave heights, and durations.
  final CascadeStyleConfig config;

  @override
  Widget build(
    BuildContext context, {
    required OTPinController controller,
    required FocusNode focusNode,
  }) {
    return _CascadeStyleWidget(
      config: config,
      controller: controller,
      focusNode: focusNode,
    );
  }
}

class _CascadeStyleWidget extends StatefulWidget {
  const _CascadeStyleWidget({
    required this.config,
    required this.controller,
    required this.focusNode,
  });

  final CascadeStyleConfig config;
  final OTPinController controller;
  final FocusNode focusNode;

  @override
  State<_CascadeStyleWidget> createState() => _CascadeStyleWidgetState();
}

class _CascadeStyleWidgetState extends State<_CascadeStyleWidget>
    with TickerProviderStateMixin {
  // ─── Animation Controllers ───
  late AnimationController _cursorController;
  late AnimationController _ambientController;
  late AnimationController _waveController;
  late AnimationController _morphController;
  late AnimationController _successCheckController;
  late AnimationController _errorShakeController;
  late AnimationController _errorResetController;

  // ─── Entry controllers (one per field) ───
  late List<AnimationController> _entryControllers;

  // ─── Curved Animations ───
  late Animation<double> _cursorAnimation;
  late Animation<double> _ambientAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _successCheckAnimation;
  late Animation<double> _errorShakeAnimation;

  OTPinState _previousState = OTPinState.empty;
  List<String> _previousDigits = [];

  CascadeStyleConfig get _config => widget.config;
  OTPinController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _ctrl.addListener(_onControllerChanged);
    _previousDigits = List.from(_ctrl.digits);

    _cursorController.repeat(reverse: true);
    _ambientController.repeat(reverse: true);
  }

  void _initAnimations() {
    // 1. Cursor blink
    _cursorController = AnimationController(
      vsync: this,
      duration: _config.cursorBlinkDuration,
    );
    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _cursorController,
    );

    // 2. Ambient breathing
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ambientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ambientController,
        curve: Curves.easeInOut,
      ),
    );

    // 3. Digit entry spring
    _entryControllers = List.generate(
      _ctrl.length,
      (_) => AnimationController(
        vsync: this,
        duration: _config.digitEntryDuration,
      ),
    );

    // 4. Verifying wave
    _waveController = AnimationController(
      vsync: this,
      duration: _config.waveCycleDuration,
    );

    // 5. Success morph
    _morphController = AnimationController(
      vsync: this,
      duration: _config.morphDuration,
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );

    // 6. Success checkmark pop
    _successCheckController = AnimationController(
      vsync: this,
      duration: _config.successCheckDuration,
    );
    _successCheckAnimation = CurvedAnimation(
      parent: _successCheckController,
      curve: Curves.elasticOut,
    );

    // 7. Error shake
    _errorShakeController = AnimationController(
      vsync: this,
      duration: _config.errorShakeDuration,
    );
    _errorShakeAnimation = CurvedAnimation(
      parent: _errorShakeController,
      curve: Curves.linear,
    );

    // 8. Error reset
    _errorResetController = AnimationController(
      vsync: this,
      duration: _config.errorResetDuration,
    );
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onControllerChanged);
    _cursorController.dispose();
    _ambientController.dispose();
    _waveController.dispose();
    _morphController.dispose();
    _successCheckController.dispose();
    _errorShakeController.dispose();
    _errorResetController.dispose();
    for (final c in _entryControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    final newState = _ctrl.state;
    final newDigits = _ctrl.digits;

    for (int i = 0; i < _ctrl.length; i++) {
      if (i < _previousDigits.length &&
          _previousDigits[i].isEmpty &&
          newDigits[i].isNotEmpty) {
        _entryControllers[i].forward(from: 0);
      } else if (newDigits[i].isEmpty) {
        _entryControllers[i].reset();
      }
    }
    _previousDigits = List.from(newDigits);

    if (newState != _previousState) {
      _handleStateTransition(_previousState, newState);
      _previousState = newState;
    }

    setState(() {});
  }

  void _handleStateTransition(OTPinState from, OTPinState to) {
    switch (to) {
      case OTPinState.empty:
        _ambientController.repeat(reverse: true);
        _waveController.stop();
        _waveController.reset();
        _morphController.reset();
        _successCheckController.reset();
      case OTPinState.typing:
        _ambientController.stop();
        _waveController.stop();
        _waveController.reset();
        _morphController.reset();
        _successCheckController.reset();
      case OTPinState.verifying:
        _startVerifyingAnimation();
      case OTPinState.success:
        _startSuccessAnimation();
      case OTPinState.error:
        _startErrorAnimation();
    }
  }

  Future<void> _startVerifyingAnimation() async {
    _waveController.repeat();
  }

  Future<void> _startSuccessAnimation() async {
    _waveController.stop();
    _waveController.reset();
    await _morphController.forward(from: 0);
    await _successCheckController.forward(from: 0);
  }

  Future<void> _startErrorAnimation() async {
    _waveController.stop();
    _waveController.reset();
    await _errorShakeController.forward(from: 0);
    _errorResetController.forward(from: 0);
    await Future.delayed(_config.errorResetDuration);
    _errorShakeController.reset();
    _errorResetController.reset();
    _ctrl.resetAfterError();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.focusNode.requestFocus(),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _cursorController,
          _ambientController,
          _waveController,
          _morphController,
          _successCheckController,
          _errorShakeController,
          _errorResetController,
          ..._entryControllers,
        ]),
        builder: (context, _) => _buildCascade(),
      ),
    );
  }

  Widget _buildCascade() {
    final length = _ctrl.length;
    final morphVal = _morphAnimation.value;
    final currentSpacing = _lerpDouble(_config.fieldSpacing, 0.0, morphVal);

    final totalWidth = length * _config.fieldSize + (length - 1) * currentSpacing;
    final totalHeight = _config.fieldSize + _config.waveHeight * 2 + 16.0;

    return SizedBox(
      width: totalWidth + 24.0,
      height: totalHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // ─── Laser Shimmer Beam (active during verification) ───
          if (_waveController.isAnimating)
            Positioned(
              left: 12.0,
              right: 12.0,
              height: _config.fieldSize,
              child: CustomPaint(
                painter: CascadeShimmerPainter(
                  progress: _waveController.value,
                  beamColor: _config.waveBeamColor,
                  opacity: 0.9,
                ),
              ),
            ),

          // ─── Digit Fields Row ───
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(length, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: currentSpacing / 2),
                child: _buildSingleField(index, length, morphVal),
              );
            }),
          ),

          // ─── Success Badge Overlay (appears when morphed) ───
          if (morphVal > 0.6)
            Transform.scale(
              scale: _successCheckAnimation.value,
              child: _buildSuccessBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleField(int index, int length, double morphVal) {
    // Vertical wave oscillation (verifying state).
    double yOffset = 0.0;
    double waveScale = 1.0;

    if (_waveController.isAnimating) {
      final phase = (index / length) * 2 * math.pi;
      final waveSin = math.sin(_waveController.value * 2 * math.pi - phase);
      yOffset = -waveSin * _config.waveHeight;
      waveScale = 1.0 + (waveSin > 0 ? waveSin * 0.04 : 0.0);
    } else if (_ctrl.state == OTPinState.empty) {
      // Subtle ambient breathing float.
      yOffset = math.sin(_ambientAnimation.value * math.pi) * 1.5;
    }

    // Horizontal staggered shake (error state).
    double shakeX = 0.0;
    if (_errorShakeController.isAnimating) {
      final progress = _errorShakeAnimation.value;
      final staggered = (progress - index * 0.06).clamp(0.0, 1.0);
      shakeX = math.sin(staggered * 4 * math.pi) * (1.0 - progress) * 8.0;
    }

    // Entry pop animation.
    final entryController = _entryControllers[index];
    final entryVal = entryController.value;
    final digitScale = entryController.isAnimating
        ? CurvedAnimation(parent: entryController, curve: Curves.elasticOut).value
        : (_ctrl.digits[index].isNotEmpty ? 1.0 : 0.0);

    final digitOffset = entryController.isAnimating
        ? Offset(0, -10 * (1.0 - CurvedAnimation(parent: entryController, curve: Curves.easeOut).value))
        : Offset.zero;

    final boxScale = entryController.isAnimating
        ? 1.0 + math.sin(entryVal * math.pi) * 0.08
        : waveScale;

    // Capsule border radius morphing.
    final baseRadius = _config.fieldBorderRadius;
    BorderRadius borderRadius;

    if (length == 1) {
      borderRadius = BorderRadius.circular(baseRadius);
    } else if (index == 0) {
      // First box: outer left corners remain rounded, inner right corners flatten.
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(baseRadius * 1.2),
        bottomLeft: Radius.circular(baseRadius * 1.2),
        topRight: Radius.circular(_lerpDouble(baseRadius, 0.0, morphVal)),
        bottomRight: Radius.circular(_lerpDouble(baseRadius, 0.0, morphVal)),
      );
    } else if (index == length - 1) {
      // Last box: outer right corners remain rounded, inner left corners flatten.
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(_lerpDouble(baseRadius, 0.0, morphVal)),
        bottomLeft: Radius.circular(_lerpDouble(baseRadius, 0.0, morphVal)),
        topRight: Radius.circular(baseRadius * 1.2),
        bottomRight: Radius.circular(baseRadius * 1.2),
      );
    } else {
      // Middle boxes: all corners flatten.
      borderRadius = BorderRadius.circular(
        _lerpDouble(baseRadius, 0.0, morphVal),
      );
    }

    // Colors
    final isFocused = _ctrl.focusedIndex == index &&
        (_ctrl.state == OTPinState.empty || _ctrl.state == OTPinState.typing);

    final borderColor = _borderColorForField(index, morphVal);
    final glowColor = _glowColorForField(index);
    final glowOpacity = _glowOpacityForField(index);
    final cursorOpacity = isFocused ? _cursorAnimation.value : 0.0;

    // Field background color during success morph.
    final bgColor = morphVal > 0.0
        ? Color.lerp(
            _config.fieldBackgroundColor,
            _config.successColor.withValues(alpha: 0.18),
            morphVal,
          )
        : _config.fieldBackgroundColor;

    return Transform.translate(
      offset: Offset(shakeX, yOffset),
      child: CascadeField(
        config: _config,
        digit: _ctrl.digits[index],
        isFocused: isFocused,
        borderColor: borderColor,
        borderRadius: borderRadius,
        glowColor: glowColor,
        glowOpacity: glowOpacity,
        cursorOpacity: cursorOpacity,
        digitScale: digitScale,
        digitOffset: digitOffset,
        digitOpacity: 1.0 - morphVal,
        scale: boxScale,
        backgroundColor: bgColor,
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _config.successColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _config.successColor,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _config.successGlowColor,
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_config.successIcon != null) ...[
            Icon(
              _config.successIcon,
              color: _config.successIconColor ?? Colors.white,
              size: _config.successIconSize ?? 24.0,
            ),
          ],
          if (_config.successText != null &&
              _config.successText!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              _config.successText!,
              style: _config.successTextStyle ??
                  TextStyle(
                    color: _config.successIconColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Color _borderColorForField(int index, double morphVal) {
    if (morphVal > 0.0) {
      return Color.lerp(
        _config.focusedBorderColor,
        _config.successColor,
        morphVal,
      )!;
    }

    switch (_ctrl.state) {
      case OTPinState.empty:
        return _config.emptyBorderColor;
      case OTPinState.typing:
        if (_ctrl.focusedIndex == index && _ctrl.digits[index].isEmpty) {
          return _config.focusedBorderColor;
        }
        if (_ctrl.digits[index].isNotEmpty) {
          return _config.filledBorderColor;
        }
        return _config.emptyBorderColor;
      case OTPinState.verifying:
        return _config.focusedBorderColor;
      case OTPinState.success:
        return _config.successColor;
      case OTPinState.error:
        return _config.errorColor;
    }
  }

  Color _glowColorForField(int index) {
    switch (_ctrl.state) {
      case OTPinState.empty:
      case OTPinState.typing:
        return _config.focusedGlowColor;
      case OTPinState.verifying:
        return _config.focusedGlowColor;
      case OTPinState.success:
        return _config.successGlowColor;
      case OTPinState.error:
        return _config.errorGlowColor;
    }
  }

  double _glowOpacityForField(int index) {
    switch (_ctrl.state) {
      case OTPinState.empty:
        return 0.15;
      case OTPinState.typing:
        return (_ctrl.focusedIndex == index && _ctrl.digits[index].isEmpty)
            ? 0.7
            : 0.0;
      case OTPinState.verifying:
        return 0.6;
      case OTPinState.success:
        return 0.8;
      case OTPinState.error:
        return 0.8;
    }
  }

  double _lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
