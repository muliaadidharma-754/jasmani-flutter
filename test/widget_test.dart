import 'package:flutter_test/flutter_test.dart';

import 'package:jasmani_flutter/main.dart';

void main() {
  testWidgets('Home screen shows dashboard tiles', (WidgetTester tester) async {
    await tester.pumpWidget(const JasmaniApp());

    expect(find.text('JASMANI 2026'), findsOneWidget);
    expect(find.text('12 Menit'), findsOneWidget);
    expect(find.text('3200 Meter'), findsOneWidget);
    expect(find.text('BMI'), findsOneWidget);
    expect(find.text('Berat Ideal'), findsOneWidget);
  });
}
