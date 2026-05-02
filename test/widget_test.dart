import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shramik/main.dart';

void main() {
  testWidgets('branding loads on the splash shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BrandedLoadingScreen()));

    expect(find.text('Shramik'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
