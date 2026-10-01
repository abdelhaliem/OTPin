import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otpin/otpin.dart';

void main() {
  runApp(const OTPinExampleApp());
}

/// Example app showcasing the OTPin package with the Orbital
/// style, including all five visual states: empty, typing,
/// verifying, success, and error.
class OTPinExampleApp extends StatelessWidget {
  const OTPinExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTPin Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 4, 216),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        useMaterial3: true,
      ),
      home: const OTPinDemoScreen(),
    );
  }
}

enum DemoStyle {
  orbital('Orbital', 'Planetary Orbit & Center Convergence'),
  cascade('Cascade', 'Sinusoidal Wave & Capsule Morph');

  const DemoStyle(this.label, this.description);
  final String label;
  final String description;
}

class OTPinDemoScreen extends StatefulWidget {
  const OTPinDemoScreen({super.key});

  @override
  State<OTPinDemoScreen> createState() => _OTPinDemoScreenState();
}

class _OTPinDemoScreenState extends State<OTPinDemoScreen> {
  /// Current OTP length.
  int _otpLength = 4;

  late OTPinController _otpController;

  /// Selected animation style.
  DemoStyle _selectedStyle = DemoStyle.cascade;

  /// Controls whether the next verification succeeds or fails.
  bool _simulateSuccess = true;

  /// Tracks the current state label for display.
  String _currentStateLabel = 'Empty';

  @override
  void initState() {
    super.initState();
    _otpController = OTPinController(length: _otpLength);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _updateLength(int newLength) {
    if (newLength == _otpLength) return;
    _otpController.dispose();
    setState(() {
      _otpLength = newLength;
      _otpController = OTPinController(length: newLength);
      _currentStateLabel = 'Empty';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C16),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1424),
              Color(0xFF060911),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // ─── Style Switcher ───
                  _buildStyleSelector(),
                  const SizedBox(height: 16),

                  // ─── Length Selector ───
                  _buildLengthSelector(),
                  const SizedBox(height: 24),

                  // ─── OTP Card ───
                  _buildOtpCard(),
                  const SizedBox(height: 24),

                  // ─── Controls ───
                  _buildControls(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B),
        ),
      ),
      child: Row(
        children: DemoStyle.values.map((style) {
          final isSelected = _selectedStyle == style;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedStyle != style) {
                  _otpController.clear();
                  setState(() {
                    _selectedStyle = style;
                    _currentStateLabel = 'Empty';
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    style.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white60,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLengthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Text(
            'Digits',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (i) {
                final len = i + 3; // 3..8
                final isSelected = _otpLength == len;
                return GestureDetector(
                  onTap: () => _updateLength(len),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF2A3958),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$len',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(
                  alpha: 0.45,
                ),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'OTPin Demo',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter any $_otpLength digits to see the animation',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF1E293B),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStateIndicator(),
          const SizedBox(height: 32),
          OTPin(
            key: ValueKey('${_selectedStyle}_$_otpLength'),
            controller: _otpController,
            length: _otpLength,
            style: _selectedStyle == DemoStyle.orbital
                ? OrbitalStyle(
                    config: const OrbitalStyleConfig(
                      fieldBackgroundColor: Color(0xFF161F33),
                      emptyBorderColor: Color(0xFF25334D),
                      focusedBorderColor: Color(0xFF3B82F6),
                      focusedGlowColor: Color(0x663B82F6),
                      filledBorderColor: Color(0xFF2563EB),
                      cursorColor: Color(0xFF60A5FA),
                      orbitGuideColor: Color(0xFF1E2B45),
                      successColor: Color(0xFF00E676),
                      successGlowColor: Color(0x6600E676),
                      successIcon: Icons.check_rounded,
                      successIconColor: Colors.white,
                    ),
                  )
                : CascadeStyle(
                    config: const CascadeStyleConfig(
                      fieldBackgroundColor: Color(0xFF161F33),
                      emptyBorderColor: Color(0xFF25334D),
                      focusedBorderColor: Color(0xFF3B82F6),
                      focusedGlowColor: Color(0x663B82F6),
                      filledBorderColor: Color(0xFF2563EB),
                      cursorColor: Color(0xFF60A5FA),
                      waveBeamColor: Color(0xFF60A5FA),
                      successColor: Color(0xFF00E676),
                      successGlowColor: Color(0x6600E676),
                      successIcon: Icons.check_rounded,
                      successIconColor: Colors.white,
                      successText: 'Verified',
                      waveHeight: 14.0,
                    ),
                  ),
            onCompleted: _onOtpCompleted,
            onChanged: _onOtpChanged,
          ),
          const SizedBox(height: 32),
          _buildResendRow(),
        ],
      ),
    );
  }

  Widget _buildStateIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Row(
        key: ValueKey(_currentStateLabel),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _stateColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'State: $_currentStateLabel',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(
                  color: _stateColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Color get _stateColor {
    return switch (_currentStateLabel) {
      'Empty' => Colors.white38,
      'Typing' => const Color(0xFF3B82F6),
      'Verifying' => const Color(0xFFFFAB40),
      'Success' => const Color(0xFF00E676),
      'Error' => const Color(0xFFFF5252),
      _ => Colors.white38,
    };
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code?",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white38,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Resend',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(
                  color: const Color(0xFF60A5FA),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111726),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1E293B),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulation Controls',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Material(
            type: MaterialType.transparency,
            child: SwitchListTile(
              value: _simulateSuccess,
              onChanged: (v) =>
                  setState(() => _simulateSuccess = v),
              title: Text(
                _simulateSuccess
                    ? 'Simulate: Success ✓'
                    : 'Simulate: Error ✗',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              subtitle: Text(
                'Toggle to test success or error animations',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Colors.white30),
              ),
              activeThumbColor: const Color(0xFF00E676),
              inactiveThumbColor: const Color(0xFFFF5252),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    _otpController.clear();
                    _otpController.setText(
                      List.generate(
                        _otpLength,
                        (_) => math.Random().nextInt(10).toString(),
                      ).join(),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Auto Test OTP'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _otpController.clear();
                  setState(() => _currentStateLabel = 'Empty');
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Color(0xFF2A3958)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Callbacks ───

  Future<bool> _onOtpCompleted(String code) async {
    setState(() => _currentStateLabel = 'Verifying');

    // Simulate network delay.
    await Future.delayed(
      Duration(milliseconds: 1500 + math.Random().nextInt(1000)),
    );

    if (_simulateSuccess) {
      setState(() => _currentStateLabel = 'Success');
    } else {
      setState(() => _currentStateLabel = 'Error');
      // Reset state label after error animation completes.
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _currentStateLabel = 'Empty');
        }
      });
    }

    return _simulateSuccess;
  }

  void _onOtpChanged(String code) {
    if (code.isEmpty) {
      setState(() => _currentStateLabel = 'Empty');
    } else if (_currentStateLabel != 'Verifying' &&
        _currentStateLabel != 'Success' &&
        _currentStateLabel != 'Error') {
      setState(() => _currentStateLabel = 'Typing');
    }
  }
}
