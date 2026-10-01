import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/otpin_style.dart';
import 'otpin_controller.dart';
import 'otpin_state.dart';

/// A customizable OTP input widget that supports multiple visual
/// styles through the Strategy Pattern.
///
/// [OTPin] composes an [OTPinController] (manages digit state) with
/// an [OTPinStyle] (renders visuals), keeping input logic cleanly
/// separated from presentation.
///
/// ```dart
/// OTPin(
///   length: 4,
///   style: OrbitalStyle(),
///   onCompleted: (code) async {
///     return await verifyOTP(code);
///   },
/// )
/// ```
class OTPin extends StatefulWidget {
  /// Creates an OTP input widget.
  const OTPin({
    super.key,
    this.length = 4,
    required this.style,
    this.controller,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
  });

  /// Number of OTP digits.
  final int length;

  /// The visual style to use for rendering.
  final OTPinStyle style;

  /// An optional external controller. If null, the widget creates
  /// its own internal controller.
  final OTPinController? controller;

  /// Called when all digits have been entered. Return `true` for
  /// success or `false` for error. The widget will animate
  /// accordingly.
  final Future<bool> Function(String code)? onCompleted;

  /// Called whenever the current digit string changes.
  final ValueChanged<String>? onChanged;

  /// Whether to auto-focus the input on mount.
  final bool autoFocus;

  @override
  State<OTPin> createState() => _OTPinState();
}

class _OTPinState extends State<OTPin> {
  late OTPinController _controller;
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;
  bool _ownsController = false;
  bool _isHandlingCompletion = false;

  // Prevents re-entrant updates between the hidden TextField
  // and the OTPinController.
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _textEditingController = TextEditingController();
    _initController();
    _controller.addListener(_onOtpControllerChanged);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = OTPinController(length: widget.length);
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(covariant OTPin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onOtpControllerChanged);
      if (_ownsController) {
        _controller.dispose();
      }
      _initController();
      _controller.addListener(_onOtpControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onOtpControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Reacts to changes in the OTPinController and syncs the
  /// hidden TextField so that backspace etc. work correctly.
  void _onOtpControllerChanged() {
    widget.onChanged?.call(_controller.text);

    // Sync the hidden TextField value.
    if (!_syncing) {
      _syncing = true;
      _textEditingController.text = _controller.text;
      // Move cursor to end.
      _textEditingController.selection = TextSelection.collapsed(
        offset: _textEditingController.text.length,
      );
      _syncing = false;
    }

    if (_controller.isFilled &&
        _controller.state == OTPinState.typing &&
        !_isHandlingCompletion) {
      _handleCompleted();
    }
  }

  Future<void> _handleCompleted() async {
    _isHandlingCompletion = true;
    final code = _controller.text;
    _controller.startVerifying();

    if (widget.onCompleted != null) {
      final isValid = await widget.onCompleted!(code);
      if (isValid) {
        _controller.triggerSuccess();
      } else {
        _controller.triggerError();
      }
    }
    _isHandlingCompletion = false;
  }

  /// Called by the hidden TextField whenever its value changes.
  void _onHiddenTextChanged(String value) {
    if (_syncing) return;
    _syncing = true;

    final currentText = _controller.text;
    if (value.length > currentText.length) {
      final newChars = value.substring(currentText.length);
      for (final c in newChars.split('')) {
        _controller.addDigit(c);
      }
    } else if (value.length < currentText.length) {
      _controller.removeLastDigit();
    }

    _syncing = false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden TextField to capture keyboard input.
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 1,
            width: 1,
            child: TextField(
              controller: _textEditingController,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              onChanged: _onHiddenTextChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              enableSuggestions: false,
              autocorrect: false,
              showCursor: false,
            ),
          ),
        ),
        // Visible OTP style.
        widget.style.build(
          context,
          controller: _controller,
          focusNode: _focusNode,
        ),
      ],
    );
  }
}
