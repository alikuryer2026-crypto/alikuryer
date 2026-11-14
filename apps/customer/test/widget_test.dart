import 'package:flutter_test/flutter_test.dart';
import 'package:alikuryer_customer/main.dart';

void main() {
  testWidgets('Alikuryer customer home renders', (tester) async {
    await tester.pumpWidget(const AlikuryerApp());
    expect(find.text('Alikuryer'), findsWidgets);
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('Savatcha'), findsOneWidget);
  });
}
