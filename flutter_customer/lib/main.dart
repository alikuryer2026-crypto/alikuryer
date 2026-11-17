import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AliKuryerApp());
}

const red = Color(0xFFE50922);
const ink = Color(0xFF17171D);
const canvas = Color(0xFFF6F6F8);

class Food {
  final int id;
  final String name, category, restaurant, image;
  final int price;
  const Food(this.id, this.name, this.category, this.restaurant, this.image, this.price);
}

const foods = <Food>[
  Food(1, 'Pepperoni pitsa', 'Pitsa', 'Pitsa uyi', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=700', 84000),
  Food(2, 'Cheeseburger', 'Burger', 'Burger House', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700', 56000),
  Food(3, 'Osh', 'Milliy taom', 'Osh Markaz', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=700', 45000),
  Food(4, 'Somsa', 'Somsa', 'Milliy taomlar', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=700', 14000),
  Food(5, 'Yangi salat', 'Salat', 'Osh Markaz', 'https://images.unsplash.com/photo-1547592180-85f173990554?w=700', 29000),
  Food(6, 'Margarita pitsa', 'Pitsa', 'Pitsa uyi', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=700', 69000),
  Food(7, 'Lavash', 'Lavash', 'Lavash markazi', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=700', 38000),
  Food(8, 'Burger set', 'Burger', 'Burger House', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=700', 76000),
];

String money(int n) => '${n.toString().replaceAllMapped(RegExp(r'\\B(?=(\\d{3})+(?!\\d))'), (m) => ' ')} so‘m';

class AliKuryerApp extends StatelessWidget {
  const AliKuryerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ALI KURYER',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(seedColor: red, primary: red, surface: Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor: canvas, foregroundColor: ink, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        backgroundColor: red, foregroundColor: Colors.white,
        minimumSize: const Size(0, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
    ),
    home: const CustomerHome(),
  );
}

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});
  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int tab = 0;
  String search = '', category = 'Barchasi', restaurant = '', name = '', address = '';
  final Map<int, int> cart = {};
  final List<Map<String, dynamic>> orders = [];
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  bool loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name = prefs.getString('name') ?? '';
      address = prefs.getString('address') ?? '';
      nameCtrl.text = name; addressCtrl.text = address;
      try {
        final raw = jsonDecode(prefs.getString('cart') ?? '{}') as Map<String, dynamic>;
        for (final e in raw.entries) { cart[int.parse(e.key)] = (e.value as num).toInt(); }
        final saved = jsonDecode(prefs.getString('orders') ?? '[]') as List<dynamic>;
        orders.addAll(saved.map((e) => Map<String, dynamic>.from(e as Map)));
      } catch (_) { cart.clear(); orders.clear(); }
      loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', jsonEncode(cart.map((k, v) => MapEntry(k.toString(), v))));
    await prefs.setString('orders', jsonEncode(orders));
    await prefs.setString('name', name);
    await prefs.setString('address', address);
  }

  @override
  void dispose() { nameCtrl.dispose(); addressCtrl.dispose(); super.dispose(); }

  int get totalItems => cart.values.fold(0, (a, b) => a + b);
  int get subtotal => foods.fold(0, (sum, f) => sum + f.price * (cart[f.id] ?? 0));
  int get delivery => subtotal == 0 ? 0 : 12000;

  void change(Food food, int delta) {
    setState(() {
      final n = (cart[food.id] ?? 0) + delta;
      if (n <= 0) { cart.remove(food.id); } else { cart[food.id] = n; }
    });
    _save();
  }

  void go(int next) => setState(() { tab = next; if (next != 0) restaurant = ''; });
  void snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Widget photo(String url, {double height = 145}) => Image.network(
    url, height: height, width: double.infinity, fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(height: height, color: const Color(0xFFFFECEE),
      alignment: Alignment.center, child: const Icon(Icons.restaurant, color: red, size: 38)),
  );

  void details(Food f) {
    int qty = 1;
    showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(18), child: photo(f.image, height: 205)),
          const SizedBox(height: 16), Text(f.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5), Text(f.restaurant, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          const Text('Tarkib va porsiya tafsilotlari restoran tomonidan tasdiqlanadi.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton.filledTonal(onPressed: qty > 1 ? () => refresh(() => qty--) : null, icon: const Icon(Icons.remove)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Text('$qty', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
            IconButton.filledTonal(onPressed: () => refresh(() => qty++), icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () { change(f, qty); Navigator.pop(ctx); snack('Savatchaga qo‘shildi'); },
            child: Text('Savatchaga qo‘shish • ${money(f.price * qty)}'))),
        ]),
      ))));
  }

  Widget foodCard(Food f) => InkWell(onTap: () => details(f), borderRadius: BorderRadius.circular(19),
    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(19),
      boxShadow: const [BoxShadow(color: Color(0x0B000000), blurRadius: 16, offset: Offset(0, 6))]),
      clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        photo(f.image, height: 125),
        Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(f.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 4), Text(f.restaurant, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: Text(money(f.price), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            SizedBox(width: 37, height: 37, child: IconButton.filled(
              padding: EdgeInsets.zero, onPressed: () => change(f, 1), icon: const Icon(Icons.add))),
          ]),
        ])),
      ])));

  Widget heading(String title, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(top: 23, bottom: 13),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
      if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
    ]));

  Widget restaurantTile(String r) {
    final f = foods.firstWhere((x) => x.restaurant == r);
    return InkWell(onTap: () => setState(() { restaurant = r; tab = 0; }),
      borderRadius: BorderRadius.circular(18),
      child: Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 82, child: photo(f.image, height: 75))),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5), const Text('Menyu va taomlarni ko‘rish', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: red),
        ])));
  }

  Widget homeView() {
    if (restaurant.isNotEmpty) {
      final selected = foods.where((f) => f.restaurant == restaurant).toList();
      return ListView(padding: const EdgeInsets.all(16), children: [
        TextButton.icon(onPressed: () => setState(() => restaurant = ''), icon: const Icon(Icons.arrow_back), label: const Text('Restoranlarga qaytish')),
        ClipRRect(borderRadius: BorderRadius.circular(22), child: photo(selected.first.image, height: 190)),
        heading(restaurant, subtitle: 'Restoran menyusi • namunaviy ma’lumotlar'),
        const Text('Taomlarni tanlang', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 15), foodGrid(selected),
      ]);
    }
    final restaurants = foods.map((f) => f.restaurant).toSet().where(
      (r) => search.isEmpty || r.toLowerCase().contains(search.toLowerCase()) ||
        foods.any((f) => f.restaurant == r && f.name.toLowerCase().contains(search.toLowerCase()))).toList();
    final selected = foods.where((f) =>
      (category == 'Barchasi' || f.category == category) &&
      (search.isEmpty || f.name.toLowerCase().contains(search.toLowerCase()) ||
       f.restaurant.toLowerCase().contains(search.toLowerCase()))).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      InkWell(onTap: () => go(3), child: Row(children: [
        const Icon(Icons.location_on, color: red), const SizedBox(width: 6),
        Expanded(child: Text(address.isEmpty ? 'Yetkazish manzilini kiriting' : address,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
        const Icon(Icons.keyboard_arrow_down),
      ])),
      const SizedBox(height: 15),
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(colors: [Color(0xFF1C1C23), Color(0xFFC30C24)])),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ALI KURYER', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 2)),
            const SizedBox(height: 10),
            const Text('Mazali taomlar\nendi yanada yaqin!', style: TextStyle(
              fontSize: 25, height: 1.15, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Sevimli restoraningizni tanlang', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ])),
          const Icon(Icons.delivery_dining, size: 85, color: Colors.white),
        ])),
      const SizedBox(height: 18),
      TextField(onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(hintText: 'Taom yoki restoran qidiring',
          prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
      heading('Kategoriyalar'),
      SizedBox(height: 43, child: ListView(scrollDirection: Axis.horizontal, children:
        ['Barchasi', 'Pitsa', 'Burger', 'Lavash', 'Somsa', 'Milliy taom', 'Salat'].map((c) =>
          Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c),
            selected: category == c, onSelected: (_) => setState(() => category = c)))).toList())),
      heading('Mashhur restoranlar'),
      ...restaurants.map(restaurantTile),
      heading('Taomlar', subtitle: 'Narxlar namunaviy, hamkorlar bazasi hali ulanmagan'),
      foodGrid(selected),
    ]);
  }

  Widget foodGrid(List<Food> items) {
    if (items.isEmpty) return const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Hech narsa topilmadi')));
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth > 650 ? 3 : 2;
      return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .74),
        itemBuilder: (ctx, i) => foodCard(items[i]));
    });
  }

  Widget cartView() {
    final chosen = foods.where((f) => (cart[f.id] ?? 0) > 0).toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      heading('Savatcham'),
      if (chosen.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Savatcha bo‘sh. Taom tanlang.'))),
      ...chosen.map((f) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 67, child: photo(f.image, height: 66))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(money(f.price), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          IconButton(onPressed: () => change(f, -1), icon: const Icon(Icons.remove_circle_outline)),
          Text('${cart[f.id]}', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => change(f, 1), icon: const Icon(Icons.add_circle, color: red)),
        ]))),
      if (chosen.isNotEmpty) Container(padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
        child: Column(children: [
          rowAmount('Taomlar', money(subtotal)), const SizedBox(height: 12),
          rowAmount('Yetkazish (namuna)', money(delivery)), const Divider(height: 25),
          rowAmount('Jami', money(subtotal + delivery), bold: true),
          const SizedBox(height: 16),
          const Text('Sinov: haqiqiy buyurtma yuborilmaydi va to‘lov olinmaydi.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: checkout, child: const Text('Buyurtmani davom ettirish'))),
        ])),
    ]);
  }

  Widget rowAmount(String a, String b, {bool bold = false}) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(a, style: TextStyle(fontWeight: bold ? FontWeight.w900 : FontWeight.w400)),
    Text(b, style: TextStyle(fontWeight: FontWeight.w900, fontSize: bold ? 18 : 14)),
  ]);

  void checkout() {
    if (address.trim().isEmpty) { snack('Avval Profil bo‘limida manzilni saqlang'); go(3); return; }
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Sinov buyurtmasi'),
      content: Text('Manzil: $address\nJami: ${money(subtotal + delivery)}\n\nBu buyurtma serverga yuborilmaydi.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Bekor qilish')),
        FilledButton(onPressed: () {
          setState(() {
            orders.insert(0, {'id': 'AK-${DateTime.now().millisecondsSinceEpoch}', 'total': subtotal + delivery,
              'date': DateTime.now().toIso8601String(), 'address': address, 'status': 'Sinov'});
            cart.clear(); tab = 2;
          });
          _save(); Navigator.pop(ctx); snack('Sinov buyurtmasi saqlandi');
        }, child: const Text('Tasdiqlash')),
      ],
    ));
  }

  Widget ordersView() => ListView(padding: const EdgeInsets.all(16), children: [
    heading('Buyurtmalarim'),
    if (orders.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Hozircha buyurtmalar yo‘q'))),
    ...orders.map((o) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(o['id'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(o['address'].toString(), style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        rowAmount('Sinov buyurtmasi', money((o['total'] as num).toInt())),
      ]))),
  ]);

  Widget profileView() => ListView(padding: const EdgeInsets.all(16), children: [
    heading('Mening profilim'),
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CircleAvatar(radius: 32, backgroundColor: Color(0xFFFFE9EC),
          child: Icon(Icons.person, color: red, size: 34)),
        const SizedBox(height: 18),
        const Text('Ismingiz'), const SizedBox(height: 7),
        TextField(controller: nameCtrl, decoration: const InputDecoration(
          hintText: 'Ism-familiya', border: OutlineInputBorder())),
        const SizedBox(height: 18),
        const Text('Yetkazish manzili'), const SizedBox(height: 7),
        TextField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(
          hintText: 'Ko‘cha, uy, xonadon', border: OutlineInputBorder())),
        const SizedBox(height: 17),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () {
          setState(() { name = nameCtrl.text.trim(); address = addressCtrl.text.trim(); });
          _save(); snack('Profil saqlandi');
        }, child: const Text('Saqlash'))),
        const SizedBox(height: 13),
        const Text('Google/telefon orqali kirish va xarita hali ulanmagan.',
          style: TextStyle(color: Colors.grey, fontSize: 12)),
      ])),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text.rich(TextSpan(children: [
      TextSpan(text: 'ALI', style: TextStyle(fontWeight: FontWeight.w900, color: ink)),
      TextSpan(text: 'KURYER', style: TextStyle(fontWeight: FontWeight.w900, color: red)),
    ])), actions: [
      IconButton(tooltip: 'Savatcha', onPressed: () => go(1),
        icon: Badge(isLabelVisible: totalItems > 0, label: Text('$totalItems'),
          child: const Icon(Icons.shopping_bag_outlined))),
    ]),
    body: !loaded ? const Center(child: CircularProgressIndicator()) : IndexedStack(
      index: tab, children: [homeView(), cartView(), ordersView(), profileView()]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: go,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Asosiy'),
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Savatcha'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Buyurtmalar'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ]),
  );
}
