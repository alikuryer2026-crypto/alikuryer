import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alikuryer_customer/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('New customer sees the branded welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AliKuryerApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Alikuryer'), findsWidgets);
    expect(find.text('Boshlash'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Returning customer skips onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    await tester.pumpWidget(const AliKuryerApp());
    await tester.pumpAndSettle();
    expect(find.text('Boshlash'), findsNothing);
    expect(find.text('Alikuryer'), findsWidgets);
  });
}
