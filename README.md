<p align="center">
  <img src="https://raw.githubusercontent.com/abdelhaliem/OTPin/main/doc/logo.png" width="140" alt="OTPin Logo" style="border-radius: 28px;">
</p>

<p align="center">
  <h1 align="center">OTPin</h1>
  <p align="center">
    <strong>Beautifully animated OTP input for Flutter</strong>
  </p>
  <p align="center">
    <a href="https://pub.dev/packages/otpin"><img src="https://img.shields.io/pub/v/otpin.svg" alt="pub version"></a>
    <a href="https://github.com/abdelhaliem/OTPin/actions"><img src="https://img.shields.io/github/actions/workflow/status/abdelhaliem/OTPin/ci.yml?branch=main" alt="build"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="license"></a>
    <a href="https://flutter.dev"><img src="https://img.shields.io/badge/platform-Flutter-02569B?logo=flutter" alt="platform"></a>
  </p>
</p>

---

**OTPin** is a plug-and-play OTP (One-Time Password) input widget for Flutter that ships with multiple, richly animated visual styles. Each style supports five animated states — **Empty**, **Typing**, **Verifying**, **Success**, and **Error** — and is fully customizable.

> **Zero external dependencies.** Built entirely with Flutter's built-in animation system.

---

## ✨ Styles

### Orbital Style

Digit fields orbit in a circle during verification, converge to a success icon on success, and shake on error.

<p align="center">
  <img src="https://raw.githubusercontent.com/abdelhaliem/OTPin/main/doc/orbital_demo.gif" width="300" alt="Orbital Style Demo">
</p>

### Cascade Style

A cascading sinusoidal wave ripples through fields during verification. On success, fields morph into a unified capsule with a checkmark. On error, a staggered domino shake effect plays.

<p align="center">
  <img src="https://raw.githubusercontent.com/abdelhaliem/OTPin/main/doc/cascade_demo.gif" width="300" alt="Cascade Style Demo">
</p>

---

## 🚀 Installation

Add `otpin` to your `pubspec.yaml`:

```yaml
dependencies:
  otpin: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## 📖 Quick Start

```dart
import 'package:otpin/otpin.dart';

OTPin(
  length: 4,
  style: OrbitalStyle(),
  onCompleted: (code) async {
    final isValid = await verifyOTP(code);
    return isValid; // true → success animation, false → error animation
  },
)
```

That's it — a fully animated OTP input in **3 lines**.

---

## 🎨 Styles & Usage

### Orbital Style

```dart
OTPin(
  length: 4,
  style: OrbitalStyle(
    config: OrbitalStyleConfig(
      // ─── Colors ───
      focusedBorderColor: Colors.cyan,
      filledBorderColor: Colors.cyanAccent,
      emptyBorderColor: Color(0xFF25334D),
      fieldBackgroundColor: Color(0xFF141C2E),
      cursorColor: Colors.cyanAccent,
      successColor: Color(0xFF00E676),
      errorColor: Color(0xFFFF5252),

      // ─── Success Display ───
      successIcon: Icons.check_rounded,
      successIconColor: Colors.white,

      // ─── Sizing ───
      fieldSize: 60.0,
      fieldBorderRadius: 16.0,
      fieldSpacing: 12.0,
      orbitRadius: 80.0,
      orbitFieldScale: 0.7,

      // ─── Durations ───
      orbitRevolutionDuration: Duration(seconds: 3),
      successConvergeDuration: Duration(milliseconds: 600),
      errorShakeDuration: Duration(milliseconds: 500),
    ),
  ),
  onCompleted: (code) async => await api.verify(code),
  onChanged: (code) => debugPrint('Current: $code'),
)
```

#### Orbital Animation States

| State       | Animation                                                        |
| ----------- | ---------------------------------------------------------------- |
| **Empty**   | Subtle ambient pulse on all fields                               |
| **Typing**  | Blinking cursor on focused field, scale-in on digit entry        |
| **Verify**  | Fields shrink and orbit in a circle with a guide ring            |
| **Success** | Fields converge to center, revealing a success icon circle       |
| **Error**   | Horizontal shake with red flash, then auto-clear                 |

---

### Cascade Style

```dart
OTPin(
  length: 4,
  style: CascadeStyle(
    config: CascadeStyleConfig(
      // ─── Colors ───
      focusedBorderColor: Color(0xFF3B82F6),
      filledBorderColor: Color(0xFF2563EB),
      emptyBorderColor: Color(0xFF25334D),
      fieldBackgroundColor: Color(0xFF141C2E),
      cursorColor: Color(0xFF60A5FA),
      waveBeamColor: Color(0xFF60A5FA),
      successColor: Color(0xFF00E676),
      errorColor: Color(0xFFFF5252),

      // ─── Success Display ───
      successIcon: Icons.check_rounded,
      successText: 'Verified',

      // ─── Sizing ───
      fieldSize: 60.0,
      fieldBorderRadius: 16.0,
      fieldSpacing: 12.0,
      waveHeight: 14.0,

      // ─── Durations ───
      waveCycleDuration: Duration(milliseconds: 1200),
      morphDuration: Duration(milliseconds: 500),
      errorShakeDuration: Duration(milliseconds: 500),
    ),
  ),
  onCompleted: (code) async => await api.verify(code),
)
```

#### Cascade Animation States

| State       | Animation                                                        |
| ----------- | ---------------------------------------------------------------- |
| **Empty**   | Subtle ambient pulse on all fields                               |
| **Typing**  | Blinking cursor on focused field, pop-in on digit entry          |
| **Verify**  | Sinusoidal cascading wave with shimmer beam                      |
| **Success** | Fields morph into a unified capsule with checkmark + label       |
| **Error**   | Staggered domino shake with red flash, then auto-clear           |

---

## 🎮 Programmatic Control

Use `OTPinController` for full programmatic access:

```dart
final controller = OTPinController(length: 4);

// Use the controller with the widget.
OTPin(
  length: 4,
  style: OrbitalStyle(),
  controller: controller,
  onCompleted: (code) async => await api.verify(code),
)

// Set digits programmatically (e.g. from clipboard).
controller.setText('1234');

// Clear all digits.
controller.clear();

// Manually trigger states for testing.
controller.triggerSuccess();
controller.triggerError();
```

---

## 🏗️ Architecture

OTPin uses the **Strategy Pattern** to cleanly decouple visual styles from input logic:

```
┌─────────────────────────────────────────┐
│                  OTPin                  │  ← Main widget
│  ┌──────────────┐  ┌────────────────┐   │
│  │ OTPinController│  │  OTPinStyle   │   │  ← Input logic + Visual strategy
│  └──────────────┘  └───────┬────────┘   │
└─────────────────────────────┼───────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
     ┌────────┴────┐  ┌──────┴──────┐  ┌─────┴─────┐
     │ OrbitalStyle│  │CascadeStyle │  │ YourStyle │
     └─────────────┘  └─────────────┘  └───────────┘
```

### Key Components

| Component          | Responsibility                                      |
| ------------------ | --------------------------------------------------- |
| `OTPin`            | Composes controller + style, manages hidden keyboard |
| `OTPinController`  | Digit state, focus index, state machine transitions  |
| `OTPinState`       | Enum: `empty`, `typing`, `verifying`, `success`, `error` |
| `OTPinStyle`       | Abstract interface — implement to create new styles  |
| `OrbitalStyle`     | Orbital orbit/converge animation style               |
| `CascadeStyle`     | Cascading wave/morph animation style                 |

---

## 🧩 Creating a Custom Style

Implement `OTPinStyle` to create your own animated OTP input:

```dart
import 'package:otpin/otpin.dart';

class MyCustomStyle implements OTPinStyle {
  @override
  Widget build(
    BuildContext context, {
    required OTPinController controller,
    required FocusNode focusNode,
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Build your UI based on controller.state,
        // controller.digits, controller.focusedIndex, etc.
        return Row(
          children: List.generate(controller.length, (i) {
            return _buildField(controller, i);
          }),
        );
      },
    );
  }

  Widget _buildField(OTPinController controller, int index) {
    final digit = controller.digits[index];
    final isFocused = controller.focusedIndex == index;
    // ... your custom rendering
  }
}
```

Then use it:

```dart
OTPin(
  length: 6,
  style: MyCustomStyle(),
  onCompleted: (code) async => await api.verify(code),
)
```

---

## ⚙️ Configuration Reference

### OrbitalStyleConfig

| Property                   | Type       | Default                    | Description                        |
| -------------------------- | ---------- | -------------------------- | ---------------------------------- |
| `focusedBorderColor`       | `Color`    | `Color(0xFF3B82F6)`        | Border color of focused field      |
| `filledBorderColor`        | `Color`    | `Color(0xFF2563EB)`        | Border color of filled field       |
| `emptyBorderColor`         | `Color`    | `Color(0xFF25334D)`        | Border color of empty field        |
| `fieldBackgroundColor`     | `Color`    | `Color(0xFF141C2E)`        | Field background color             |
| `successColor`             | `Color`    | `Color(0xFF00E676)`        | Success state accent color         |
| `errorColor`               | `Color`    | `Color(0xFFFF5252)`        | Error state accent color           |
| `successIcon`              | `IconData` | `Icons.check_rounded`      | Icon shown on success              |
| `successChild`             | `Widget?`  | `null`                     | Custom widget instead of icon      |
| `fieldSize`                | `double`   | `60.0`                     | Width/height of each field         |
| `fieldBorderRadius`        | `double`   | `16.0`                     | Corner radius                      |
| `orbitRadius`              | `double`   | `80.0`                     | Radius of orbit circle             |
| `orbitRevolutionDuration`  | `Duration` | `2500ms`                   | Time for one full orbit            |

### CascadeStyleConfig

| Property                   | Type       | Default                    | Description                        |
| -------------------------- | ---------- | -------------------------- | ---------------------------------- |
| `focusedBorderColor`       | `Color`    | `Color(0xFF3B82F6)`        | Border color of focused field      |
| `filledBorderColor`        | `Color`    | `Color(0xFF2563EB)`        | Border color of filled field       |
| `emptyBorderColor`         | `Color`    | `Color(0xFF25334D)`        | Border color of empty field        |
| `fieldBackgroundColor`     | `Color`    | `Color(0xFF141C2E)`        | Field background color             |
| `waveBeamColor`            | `Color`    | `Color(0xFF60A5FA)`        | Shimmer beam color during verify   |
| `successColor`             | `Color`    | `Color(0xFF00E676)`        | Success state accent color         |
| `errorColor`               | `Color`    | `Color(0xFFFF5252)`        | Error state accent color           |
| `successIcon`              | `IconData` | `Icons.check_rounded`      | Icon shown on success              |
| `successText`              | `String?`  | `'Verified'`               | Label beside checkmark             |
| `fieldSize`                | `double`   | `60.0`                     | Width/height of each field         |
| `fieldBorderRadius`        | `double`   | `16.0`                     | Corner radius                      |
| `waveHeight`               | `double`   | `14.0`                     | Peak wave oscillation height       |
| `waveCycleDuration`        | `Duration` | `1200ms`                   | Duration of one wave cycle         |
| `morphDuration`            | `Duration` | `500ms`                    | Capsule morph animation duration   |

---

## 📋 API Reference

### OTPin Widget

```dart
const OTPin({
  int length = 4,             // Number of digits
  required OTPinStyle style,  // Visual style to render
  OTPinController? controller,// Optional external controller
  Future<bool> Function(String)? onCompleted, // Verification callback
  ValueChanged<String>? onChanged,            // Digit change callback
  bool autoFocus = true,      // Auto-focus on mount
})
```

### OTPinController

```dart
class OTPinController extends ChangeNotifier {
  OTPinController({required int length});

  List<String> get digits;       // Current digit values
  OTPinState get state;          // Current animation state
  int get focusedIndex;          // Currently focused field
  bool get isFilled;             // Whether all digits are entered
  String get text;               // Current OTP string

  void addDigit(String digit);   // Add a single digit
  void removeLastDigit();        // Remove last digit
  void setText(String value);    // Set all digits at once
  void clear();                  // Clear all digits
  void startVerifying();         // Transition to verifying state
  void triggerSuccess();         // Transition to success state
  void triggerError();           // Transition to error state
}
```

### OTPinState

```dart
enum OTPinState {
  empty,      // No digits entered — ambient pulse
  typing,     // User is entering digits
  verifying,  // Code submitted — loading animation
  success,    // Verification passed
  error,      // Verification failed
}
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-style`)
3. Implement your changes
4. Add tests
5. Submit a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/abdelhaliem">Abdelhaliem</a>
</p>
