import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alikuryer_customer/onboarding.dart';

void main() {
  testWidgets('Onboarding language selection and phone demo flow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var completed = false;
    await tester.pumpWidget(MaterialApp(
      home: AliOnboarding(onFinish: () => completed = true),
    ));
    expect(find.text('Alikuryer'), findsOneWidget);
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect(find.text('Tilni tanlang'), findsOneWidget);
    expect(find.text('O‘zbekcha'), findsOneWidget);
    await tester.tap(find.text('Davom etish'));
    await tester.pumpAndSettle();
    expect(find.text('Telefon raqamingiz'), findsOneWidget);
    await tester.tap(find.text('Dizaynni kirishsiz ko‘rish'));
    await tester.pump();
    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });
}
