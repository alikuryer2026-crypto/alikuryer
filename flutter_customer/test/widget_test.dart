import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alikuryer_customer/main.dart';

void main() {
  testWidgets('App starts with Alikuryer onboarding', (tester) async {
    await tester.pumpWidget(const AliKuryerApp());
    expect(find.text('Alikuryer'), findsOneWidget);
    expect(find.text('Boshlash'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
