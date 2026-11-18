import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alikuryer_customer/onboarding.dart';

void main() {
  testWidgets('Onboarding opens and navigates to language selection', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(
      home: AliOnboarding(onFinish: () {}),
    ));
    expect(find.text('Boshlash'), findsOneWidget);
    final start = find.text('Boshlash');
    await tester.ensureVisible(start);
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Tilni tanlang'), findsOneWidget);
    expect(find.text('O‘zbekcha'), findsOneWidget);
  });

  testWidgets('Phone screen can be previewed without authentication', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AliOnboarding(onFinish: () {}),
    ));
    await tester.tap(find.text('Boshlash'));
    await tester.pump();
    await tester.tap(find.text('Davom etish'));
    await tester.pump();
    expect(find.text('Telefon raqamingiz'), findsOneWidget);
    expect(find.text('Dizaynni kirishsiz ko‘rish'), findsOneWidget);
  });
}
