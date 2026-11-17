import 'auth_page.dart';
import 'addresses_page.dart';
import 'restaurants_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isNotEmpty && key.isNotEmpty) {
    try {
      await Supabase.initialize(url: url, anonKey: key);
    } catch (error) {
      debugPrint('Supabase initialization failed: $error');
    }
  }
  runApp(const AlikuryerApp());
}

class AlikuryerApp extends StatelessWidget {
  const AlikuryerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Alikuryer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE21D2B)),
      useMaterial3: true,
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
  String query = '';
  final cart = <String, int>{};
  final prices = <String, int>{};

  void add(String name, int price) => setState(() {
    cart[name] = (cart[name] ?? 0) + 1;
    prices[name] = price;
  });

  Future<List<Map<String, dynamic>>> loadMenu() async {
    if (!Supabase.instance.isInitialized) return [];
    final result = await Supabase.instance.client
        .from('menu_items')
        .select('id,name,price_uzs')
        .eq('is_available', true)
        .limit(50);
    return List<Map<String, dynamic>>.from(result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alikuryer',
      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE21D2B)))),
    body: IndexedStack(index: tab, children: [catalog(), cartPage(), profilePage()]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Asosiy'),
        NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Savatcha'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    ),
  );

  Widget catalog() => Container(
    color: const Color(0xFFF8F8FA),
    child: ListView(padding: EdgeInsets.zero, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
        decoration: const BoxDecoration(
          color: Color(0xFFE50914),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.location_on, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Manzilingiz', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Yetkazib berish manzilini tanlang',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ])),
            Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ]),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => query = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Taom yoki restoran qidirish...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: const Icon(Icons.tune),
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 166, width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFFE50914), Color(0xFF8F0710), Color(0xFF191919)]),
            ),
            child: Stack(children: [
              const Positioned(right: -10, bottom: -12, child: Icon(
                Icons.local_pizza, size: 165, color: Color(0xFFFFB13D))),
              Positioned(left: 18, top: 17, right: 125, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('AKSIYA!', style: TextStyle(color: Colors.white,
                    fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  const Text('Pitsalarga -30%', style: TextStyle(color: Colors.white,
                    fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: const Color(0xFFE50914)),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RestaurantsPage())),
                    child: const Text('Restoranlarni ko‘rish'),
                  ),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Nima buyurtma qilamiz?', style: TextStyle(
            fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          SizedBox(height: 102, child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _FoodCategory(icon: Icons.local_pizza, title: 'Pitsa'),
              _FoodCategory(icon: Icons.lunch_dining, title: 'Burger'),
              _FoodCategory(icon: Icons.kebab_dining, title: 'Lavash'),
              _FoodCategory(icon: Icons.bakery_dining, title: 'Somsa'),
              _FoodCategory(icon: Icons.ramen_dining, title: 'Boshqa'),
            ],
          )),
          const SizedBox(height: 20),
          Row(children: [
            const Expanded(child: Text('Mashhur restoranlar', style: TextStyle(
              fontSize: 21, fontWeight: FontWeight.w800))),
            TextButton(onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RestaurantsPage())),
              child: const Text('Hammasi')),
          ]),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RestaurantsPage())),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(18)),
              child: const Row(children: [
                CircleAvatar(radius: 30, backgroundColor: Color(0xFFFFE5E5),
                  child: Icon(Icons.storefront, size: 32, color: Color(0xFFE50914))),
                SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Restoranlarni kashf eting', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Yaqin restoranlar va taomlar'),
                  ])),
                Icon(Icons.chevron_right),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Taomlar', style: TextStyle(
            fontSize: 21, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: loadMenu(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(padding: EdgeInsets.all(20),
                  child: Text('Taomlarni yuklashda xatolik'));
              }
              if (!snapshot.hasData) return const Center(
                child: CircularProgressIndicator());
              final items = snapshot.data!.where((item) =>
                item['name'].toString().toLowerCase().contains(query)).toList();
              if (items.isEmpty) return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('Hozircha taomlar mavjud emas.'));
              return Column(children: items.map((item) {
                final name = item['name'].toString();
                final price = (item['price_uzs'] as num).round();
                return Card(color: Colors.white, elevation: 0,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFEEEE),
                      child: Icon(Icons.restaurant, color: Color(0xFFE50914))),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('$price so‘m'),
                    trailing: IconButton.filled(
                      onPressed: () => add(name, price),
                      icon: const Icon(Icons.add)),
                  ));
              }).toList());
            },
          ),
        ],
      )),
    ]),
  );

  Widget cartPage() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Savatcha', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    if (cart.isEmpty) const Text('Savatchangiz bo‘sh'),
    ...cart.entries.map((entry) => ListTile(
      title: Text(entry.key),
      subtitle: Text('Soni: '+entry.value.toString()),
      trailing: IconButton(icon: const Icon(Icons.remove_circle_outline),
        onPressed: () => setState(() {
          if (entry.value <= 1) { cart.remove(entry.key); }
          else { cart[entry.key] = entry.value - 1; }
        })),
    )),
    Text('Jami: '+cart.entries.fold<int>(0, (sum, e) =>
      sum + e.value * (prices[e.key] ?? 0)).toString()+' so‘m',
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    const Text('Buyurtma berish server funksiyalari qo‘shilgach yoqiladi.'),
  ]);

  Widget profilePage() => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.person_outline, size: 70),
      const Text('Mijoz profili', style: TextStyle(fontSize: 24)),
      const SizedBox(height: 12),
      FilledButton(onPressed: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthPage()));
        if (mounted) setState(() {});
      }, child: const Text('Kirish / Ro‘yxatdan o‘tish')),
      OutlinedButton(onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AddressesPage())),
        child: const Text('Mening manzillarim')),
      if (Supabase.instance.isInitialized && Supabase.instance.client.auth.currentUser != null)
        TextButton(onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          if (mounted) setState(() {});
        }, child: const Text('Chiqish')),
    ],
  ));
}

class _FoodCategory extends StatelessWidget {
  const _FoodCategory({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) => SizedBox(width: 83,
    child: Column(children: [
      Container(width: 62, height: 62,
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(18)),
        child: Icon(icon, color: const Color(0xFFE50914), size: 32)),
      const SizedBox(height: 8),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]));
}
