import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otpin/otpin.dart';

void main() {
  group('OTPinController', () {
    late OTPinController controller;

    setUp(() {
      controller = OTPinController(length: 4);
    });

    test('starts in empty state', () {
      expect(controller.state, OTPinState.empty);
      expect(controller.digits, ['', '', '', '']);
      expect(controller.focusedIndex, 0);
      expect(controller.isFilled, false);
    });

    test('addDigit adds to the first empty slot', () {
      controller.addDigit('1');
      expect(controller.digits[0], '1');
      expect(controller.focusedIndex, 1);
      expect(controller.state, OTPinState.typing);
    });

    test('addDigit fills sequentially', () {
      controller.addDigit('1');
      controller.addDigit('2');
      controller.addDigit('3');
      expect(controller.digits, ['1', '2', '3', '']);
      expect(controller.focusedIndex, 3);
    });

    test('isFilled returns true when all slots filled', () {
      controller.addDigit('1');
      controller.addDigit('2');
      controller.addDigit('3');
      controller.addDigit('4');
      expect(controller.isFilled, true);
      expect(controller.text, '1234');
    });

    test('removeLastDigit removes the last filled digit', () {
      controller.addDigit('1');
      controller.addDigit('2');
      controller.removeLastDigit();
      expect(controller.digits, ['1', '', '', '']);
      expect(controller.focusedIndex, 1);
    });

    test('removeLastDigit on empty is a no-op', () {
      controller.removeLastDigit();
      expect(controller.digits, ['', '', '', '']);
      expect(controller.focusedIndex, 0);
    });

    test('clear resets everything', () {
      controller.addDigit('1');
      controller.addDigit('2');
      controller.clear();
      expect(controller.digits, ['', '', '', '']);
      expect(controller.state, OTPinState.empty);
      expect(controller.focusedIndex, 0);
    });

    test('setText sets all digits at once', () {
      controller.setText('5678');
      expect(controller.digits, ['5', '6', '7', '8']);
      expect(controller.isFilled, true);
    });

    test('state transitions work correctly', () {
      controller.addDigit('1');
      expect(controller.state, OTPinState.typing);

      controller.startVerifying();
      expect(controller.state, OTPinState.verifying);

      controller.triggerSuccess();
      expect(controller.state, OTPinState.success);
    });

    test('error state resets on resetAfterError', () {
      controller.addDigit('1');
      controller.addDigit('2');
      controller.addDigit('3');
      controller.addDigit('4');
      controller.startVerifying();
      controller.triggerError();
      expect(controller.state, OTPinState.error);

      controller.resetAfterError();
      expect(controller.state, OTPinState.empty);
      expect(controller.digits, ['', '', '', '']);
    });

    test('addDigit is ignored during verifying state', () {
      controller.addDigit('1');
      controller.startVerifying();
      controller.addDigit('2');
      expect(controller.digits[1], '');
    });

    test('addDigit is ignored during success state', () {
      controller.triggerSuccess();
      controller.addDigit('1');
      expect(controller.digits[0], '');
    });

    test('notifies listeners on changes', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.addDigit('1');
      controller.addDigit('2');
      controller.removeLastDigit();
      controller.clear();

      expect(notifyCount, 4);
    });
  });

  group('OrbitalStyleConfig', () {
    test('default values are set', () {
      const config = OrbitalStyleConfig();
      expect(config.fieldSize, 64.0);
      expect(config.fieldBorderRadius, 16.0);
      expect(config.orbitRadius, 80.0);
      expect(config.successIcon, Icons.check_rounded);
      expect(config.successIconColor, Colors.white);
    });

    test('copyWith creates a new instance with overrides', () {
      const config = OrbitalStyleConfig();
      final modified = config.copyWith(
        fieldSize: 48.0,
        successIcon: Icons.done_all,
        successIconColor: Colors.green,
      );
      expect(modified.fieldSize, 48.0);
      expect(modified.fieldBorderRadius, config.fieldBorderRadius);
      expect(modified.successIcon, Icons.done_all);
      expect(modified.successIconColor, Colors.green);
    });
  });
}
