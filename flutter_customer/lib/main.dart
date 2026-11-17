import 'dart:convert';
import 'package:flutter/material.dart';
import 'onboarding.dart';
import 'customer_screens.dart';
import 'reference_design.dart';
import 'courier_illustration.dart';
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

String money(int n) {
  final digits = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return '${buffer.toString()} so‘m';
}

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
    home: const AliCustomerEntry(),
  );
}

class AliCustomerEntry extends StatefulWidget {
  const AliCustomerEntry({super.key});
  @override
  State<AliCustomerEntry> createState() => _AliCustomerEntryState();
}

class _AliCustomerEntryState extends State<AliCustomerEntry> {
  bool started = false;
  bool checking = true;

  @override
  void initState() {
    super.initState();
    _restoreOnboarding();
  }

  Future<void> _restoreOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      started = prefs.getBool('onboarding_complete') ?? false;
      checking = false;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) setState(() => started = true);
  }
  @override
  Widget build(BuildContext context) => checking
    ? const Scaffold(body: Center(child: CircularProgressIndicator()))
    : started ? const CustomerHome()
    : AliOnboarding(onFinish: _finishOnboarding);
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
  final Set<int> favorites = {};
  final List<Map<String, dynamic>> orders = [];
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final homeScroll = ScrollController();
  bool loaded = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      name = prefs.getString('name') ?? '';
      favorites.addAll(prefs.getStringList('favorites')?.map(int.parse) ?? const <int>[]);
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
    await prefs.setStringList('favorites', favorites.map((e) => e.toString()).toList());
    await prefs.setString('orders', jsonEncode(orders));
    await prefs.setString('name', name);
    await prefs.setString('address', address);
  }

  @override
  void dispose() { nameCtrl.dispose(); addressCtrl.dispose(); homeScroll.dispose(); super.dispose(); }

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
  void openExtra(String route) {
    if (route == 'edit') { editCustomerName(); return; }
    if (route == 'address') { editDeliveryAddress(); return; }
    final Widget page = switch (route) {
      'hub' => AliHubScreen(open: openExtra),
      'edit' => const AliEditProfileScreen(),
      'address' => const AliAddressScreen(),
      'payment' => const AliPaymentScreen(),
      'tracking' => const AliTrackingScreen(),
      'accepted' => const AliTrackingScreen(accepted: true),
      'favorites' => AliFavoritesScreen(items: foods.where((f) => favorites.contains(f.id)).map((f) => f.name).toList()),
      'support' => const AliSupportScreen(),
      'wallet' => const AliWalletScreen(),
      _ => const AliSupportScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void editCustomerName() {
    nameCtrl.text = name;
    showModalBottomSheet<void>(context: context, isScrollControlled: true,
      showDragHandle: true, builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.viewInsetsOf(ctx).bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Profilni tahrirlash',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          TextField(controller: nameCtrl, autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Ism-familiya',
              prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              final value = nameCtrl.text.trim();
              if (value.isEmpty) return;
              setState(() => name = value);
              _save();
              Navigator.pop(ctx);
              snack('Profil saqlandi');
            }, child: const Text('Saqlash'))),
        ]),
      ));
  }

  void editDeliveryAddress() {
    addressCtrl.text = address;
    showModalBottomSheet<void>(context: context, isScrollControlled: true,
      showDragHandle: true, builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.viewInsetsOf(ctx).bottom + 22),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Yetkazish manzili', style: TextStyle(
            fontSize: 23, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Manzilni qo‘lda kiriting. Xarita keyingi bosqichda ulanadi.',
            style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 17),
          TextField(controller: addressCtrl, autofocus: true, maxLines: 2,
            decoration: const InputDecoration(hintText: 'Ko‘cha, uy, xonadon',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder())),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () {
              final value = addressCtrl.text.trim();
              if (value.isEmpty) return;
              setState(() => address = value);
              _save();
              Navigator.pop(ctx);
              snack('Manzil saqlandi');
            }, child: const Text('Manzilni saqlash'))),
        ]),
      ));
  }

  void toggleFavorite(Food f) {
    setState(() { if (!favorites.add(f.id)) favorites.remove(f.id); });
    _save();
    snack(favorites.contains(f.id) ? 'Sevimlilarga qo‘shildi' : 'Sevimlilardan olib tashlandi');
  }

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
          const SizedBox(height: 16), Row(children: [
            Expanded(child: Text(f.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
            IconButton(onPressed: () { toggleFavorite(f); refresh(() {}); },
              icon: Icon(favorites.contains(f.id) ? Icons.favorite : Icons.favorite_border, color: red)),
          ]),
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
        Stack(children: [photo(f.image, height: 125), Positioned(top: 5, right: 5,
          child: IconButton.filledTonal(onPressed: () => toggleFavorite(f),
            icon: Icon(favorites.contains(f.id) ? Icons.favorite : Icons.favorite_border, color: red)))]),
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
    return ListView(controller: homeScroll, padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      InkWell(onTap: editDeliveryAddress, child: Row(children: [
        const Icon(Icons.location_on, color: red), const SizedBox(width: 6),
        Expanded(child: Text(address.isEmpty ? 'Yetkazish manzilini kiriting' : address,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
        const Icon(Icons.keyboard_arrow_down),
      ])),
      const SizedBox(height: 15),
      Container(height: 210, clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFAA0016), Color(0xFFEB0926)])),
        child: Stack(children: [
          Positioned(right: -55, top: -38, child: Container(width: 210, height: 210,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .10)))),
          Positioned(right: -30, bottom: -45, child: Container(width: 190, height: 190,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .08)))),
          Positioned(right: -5, bottom: -5, child: SizedBox(width: 170, height: 185,
            child: const AliCourierIllustration(size: 170))),
          Padding(padding: const EdgeInsets.all(21),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ALIKURYER', style: TextStyle(color: Colors.white70,
                fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 19),
              const Text('Sevimli taomlaringiz\nendi tez va qulay!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900,
                  fontSize: 23, height: 1.15)),
              const SizedBox(height: 11),
              const SizedBox(width: 170, child: Text('Tez yetkazish • Keng tanlov • Ishonchli xizmat',
                style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4))),
              const Spacer(),
              GestureDetector(onTap: () {
                if (homeScroll.hasClients) {
                  homeScroll.animateTo(365, duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut);
                }
              },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
                child: const Text('Taomlarni tanlash  →',
                  style: TextStyle(color: red, fontWeight: FontWeight.w900, fontSize: 12)))),
            ])),
        ])),
      const SizedBox(height: 18),
      TextField(onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(hintText: 'Taom yoki restoran qidiring',
          prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
      heading('Kategoriyalar'),
      SizedBox(height: 112, child: ListView(scrollDirection: Axis.horizontal, children:
        [('Barchasi','🍽️'),('Pitsa','🍕'),('Burger','🍔'),('Lavash','🌯'),
         ('Somsa','🥟'),('Milliy taom','🍚'),('Salat','🥗')].map((c) =>
          GestureDetector(onTap: () => setState(() => category = c.$1),
            child: Container(width: 91, margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              decoration: BoxDecoration(color: Colors.white,
                border: Border.all(color: category == c.$1 ? red : const Color(0xFFF0F0F0),
                  width: category == c.$1 ? 1.5 : 1),
                boxShadow: const [BoxShadow(color: Color(0x08000000),
                  blurRadius: 12, offset: Offset(0, 3))],
                borderRadius: BorderRadius.circular(17)),
              child: Column(children: [
                Container(width: 57, height: 57, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category == c.$1 ? const Color(0xFFFFE8EB) : const Color(0xFFFFF4F2),
                    borderRadius: BorderRadius.circular(15)),
                  child: Text(c.$2, style: const TextStyle(fontSize: 32))),
                const SizedBox(height: 6),
                Text(c.$1, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                    color: category == c.$1 ? red : ink)),
              ])))).toList())),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF1F2), Colors.white]),
          border: Border.all(color: const Color(0xFFFFDBE0)),
          borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Icon(Icons.local_offer_rounded, color: red, size: 30),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Birinchi buyurtmaga', style: TextStyle(fontSize: 12,
              color: ink, fontWeight: FontWeight.w700)),
            Text('15% chegirma! (namuna)', style: TextStyle(fontSize: 16,
              color: red, fontWeight: FontWeight.w900)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(9)),
            child: const Text('PROMO ALIKURYER', style: TextStyle(
              color: red, fontSize: 9, fontWeight: FontWeight.w900))),
        ])),
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
      if (chosen.isEmpty) Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 52),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          Container(width: 104, height: 104, decoration: const BoxDecoration(
            color: AliPalette.softRed, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_basket_outlined, color: red, size: 57)),
          const SizedBox(height: 20),
          const Text('Savatchangiz bo‘sh', style: TextStyle(
            fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Mazali taomlarni tanlang va savatchaga qo‘shing',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 19),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: () => go(0), icon: const Icon(Icons.restaurant_menu),
            label: const Text('Taomlarni ko‘rish'))),
        ])),
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
      if (chosen.isNotEmpty) ...[
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            const Icon(Icons.local_offer_outlined, color: red),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Promokod', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('Chegirma tizimi keyin ulanadi',
                  style: TextStyle(fontSize: 12, color: Colors.black54))])),
            TextButton(onPressed: () => snack('Promokodlar hali ulanmagan'),
              child: const Text('Kiritish')),
          ])),
        const SizedBox(height: 12),
        InkWell(onTap: editDeliveryAddress, borderRadius: BorderRadius.circular(18),
          child: Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              const Icon(Icons.location_on_rounded, color: red),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const Text('Yetkazib berish manzili',
                  style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(address.isEmpty ? 'Manzilni tanlang' : address,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ])),
              const Icon(Icons.edit_outlined, color: red, size: 20),
            ]))),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(18)),
          child: const Row(children: [
            Icon(Icons.payments_outlined, color: red),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('To‘lov usuli', style: TextStyle(fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('Sinov rejimi — haqiqiy to‘lov olinmaydi',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
            ])),
            Icon(Icons.lock_outline, color: Colors.black38, size: 20),
          ])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(17),
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
      ],
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
    if (orders.isEmpty) Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 58),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(children: [
        Container(width: 106, height: 106, decoration: const BoxDecoration(
          color: AliPalette.softRed, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_outlined, color: red, size: 56)),
        const SizedBox(height: 20),
        const Text('Buyurtmalar hali yo‘q',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Birinchi buyurtmangizni berganingizdan so‘ng\nu shu yerda ko‘rinadi',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => go(0), icon: const Icon(Icons.restaurant_menu),
          label: const Text('Restoranlarni ko‘rish'))),
      ])),
    ...orders.map((o) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(o['id'].toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(o['address'].toString(), style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        rowAmount('Sinov buyurtmasi', money((o['total'] as num).toInt())),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: () => openExtra('tracking'),
          icon: const Icon(Icons.route), label: const Text('Kuzatish oynasi (demo)')),
      ]))),
  ]);

  Widget profileView() => ListView(padding: EdgeInsets.zero, children: [
    Container(height: 130, padding: const EdgeInsets.all(23),
      decoration: const BoxDecoration(gradient: LinearGradient(
        colors: [Color(0xFFBA001A), Color(0xFFF20A26)])),
      child: Row(children: [
        const CircleAvatar(radius: 33, backgroundColor: Colors.white,
          child: Icon(Icons.person, color: red, size: 39)),
        const SizedBox(width: 15),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name.isEmpty ? 'Mening profilim' : name,
            style: const TextStyle(color: Colors.white, fontSize: 23,
              fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          const Text('ALIKURYER mijoz kabineti',
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
        IconButton(onPressed: () => openExtra('edit'),
          icon: const Icon(Icons.edit_outlined, color: Colors.white)),
      ])),
    Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: red),
          const SizedBox(width: 10),
          Expanded(child: Text(address.isEmpty ? 'Yetkazish manzilini kiriting' : address,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700))),
          IconButton(onPressed: editDeliveryAddress,
            icon: const Icon(Icons.chevron_right)),
        ])),
      const SizedBox(height: 15),
      for (final item in [
        ('Buyurtmalarim', Icons.receipt_long_outlined, 'orders'),
        ('Sevimli taomlar', Icons.favorite_border, 'favorites'),
        ('To‘lov usullari', Icons.credit_card_outlined, 'payment'),
        ('Manzillarim', Icons.location_on_outlined, 'address'),
        ('Bonuslar va hamyon', Icons.account_balance_wallet_outlined, 'wallet'),
        ('Profilni tahrirlash', Icons.person_outline, 'edit'),
        ('Yordam markazi', Icons.support_agent_outlined, 'support'),
      ])
        Container(margin: const EdgeInsets.only(bottom: 2), color: Colors.white,
          child: ListTile(
            leading: Icon(item.$2, color: red),
            title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right, color: Colors.black45),
            onTap: () => item.$3 == 'orders' ? go(2) : openExtra(item.$3))),
      const SizedBox(height: 14),
      const Text('Sinov versiyasi. Profil va to‘lov xizmatlari bosqichma-bosqich ulanadi.',
        textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
    ])),
  ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: red, foregroundColor: Colors.white,
      title: const Text('Alikuryer', style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w900, color: Colors.white)), actions: [
      IconButton(tooltip: 'Savatcha', onPressed: () => go(1),
        icon: Badge(isLabelVisible: totalItems > 0, label: Text('$totalItems'),
          child: const Icon(Icons.shopping_bag_outlined))),
    ]),
    body: !loaded ? const Center(child: CircularProgressIndicator()) : IndexedStack(
      index: tab, children: [homeView(), cartView(), ordersView(), profileView()]),
    bottomNavigationBar: NavigationBar(backgroundColor: Colors.white, indicatorColor: AliPalette.softRed,
      selectedIndex: tab, onDestinationSelected: go,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Asosiy'),
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Savatcha'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Buyurtmalar'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
      ]),
  );
}
