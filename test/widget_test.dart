import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qine_corner/screens/payment/payment_screen.dart';

void main() {
  testWidgets('PaymentScreen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PaymentScreen(
            planName: 'Test Plan',
            planPrice: '100.00',
            planPeriod: 'Monthly',
          ),
        ),
      ),
    );

    // Verify that the Payment screen elements are present.
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Test Plan'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Select Payment Method'), findsOneWidget);
    expect(find.text('Telebirr'), findsOneWidget);
    expect(find.text('Chapa'), findsOneWidget);
    expect(find.text('Process Payment'), findsOneWidget);
  });
}