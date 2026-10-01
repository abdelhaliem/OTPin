import 'package:flutter_test/flutter_test.dart';
import 'package:otpin_example/main.dart';

void main() {
  testWidgets('Demo app renders', (tester) async {
    await tester.pumpWidget(const OTPinExampleApp());
    expect(find.text('OTPin Demo'), findsOneWidget);
  });
}
