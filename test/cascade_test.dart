import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otpin/otpin.dart';
import 'package:otpin/src/styles/cascade/cascade_field.dart';

void main() {
  group('CascadeStyleConfig', () {
    test('default values are set appropriately', () {
      const config = CascadeStyleConfig();
      expect(config.fieldSize, 64.0);
      expect(config.fieldBorderRadius, 16.0);
      expect(config.fieldSpacing, 12.0);
      expect(config.waveHeight, 14.0);
      expect(config.successIcon, Icons.check_rounded);
      expect(config.successText, 'Verified');
    });

    test('copyWith creates a new instance with overrides', () {
      const config = CascadeStyleConfig();
      final modified = config.copyWith(
        fieldSize: 52.0,
        waveHeight: 20.0,
        successText: 'Done!',
      );
      expect(modified.fieldSize, 52.0);
      expect(modified.waveHeight, 20.0);
      expect(modified.successText, 'Done!');
      expect(modified.fieldBorderRadius, config.fieldBorderRadius);
    });
  });

  group('CascadeStyle Widget Integration', () {
    testWidgets('renders OTPin with CascadeStyle', (tester) async {
      final controller = OTPinController(length: 4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OTPin(
              controller: controller,
              length: 4,
              style: CascadeStyle(),
            ),
          ),
        ),
      );

      expect(find.byType(OTPin), findsOneWidget);

      // Add a digit and verify rendering with discrete pump (since cursor repeats)
      controller.addDigit('7');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.widgetWithText(CascadeField, '7'), findsOneWidget);
    });
  });
}
