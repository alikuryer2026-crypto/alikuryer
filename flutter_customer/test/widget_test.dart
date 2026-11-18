import 'package:flutter_test/flutter_test.dart';
import 'package:alikuryer_customer/main.dart';

void main() {
  test('Food catalog has unique identifiers and valid prices', () {
    expect(foods, isNotEmpty);
    expect(foods.map((f) => f.id).toSet().length, foods.length);
    for (final food in foods) {
      expect(food.name, isNotEmpty);
      expect(food.restaurant, isNotEmpty);
      expect(food.price, greaterThan(0));
    }
  });

  test('Uzbek som formatting', () {
    expect(money(0), '0 so‘m');
    expect(money(45000), '45 000 so‘m');
    expect(money(1234567), '1 234 567 so‘m');
  });

  test('Customer app widget can be constructed', () {
    expect(const AliKuryerApp(), isA<AliKuryerApp>());
  });
}
