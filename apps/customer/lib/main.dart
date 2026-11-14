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
    await Supabase.initialize(url: url, anonKey: key);
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

  Widget catalog() => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Mazali taomlar — tez yetkazib berish',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 16),
    TextField(
      onChanged: (v) => setState(() => query = v.toLowerCase()),
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search), hintText: 'Taom qidirish',
        border: OutlineInputBorder(),
      ),
    ),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF191919), borderRadius: BorderRadius.circular(18)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('ALIKURYER', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 8),
        Text('Sevimli taomlaringiz bir joyda',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ]),
    ),
    const SizedBox(height: 22),
    TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantsPage())), icon: const Icon(Icons.storefront), label: const Text('Restoranlarni ko‘rish')),
    const Text('Taomlar', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
    FutureBuilder<List<Map<String, dynamic>>>(
      future: loadMenu(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (snapshot.hasError) return const Text('Taomlarni yuklashda xatolik');
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!.where((item) =>
          item['name'].toString().toLowerCase().contains(query)).toList();
        if (items.isEmpty) return const Padding(
          padding: EdgeInsets.all(20),
          child: Text('Hozircha taomlar mavjud emas.'),
        );
        return Column(children: items.map((item) {
          final name = item['name'].toString();
          final price = (item['price_uzs'] as num).round();
          return Card(child: ListTile(
            leading: const Icon(Icons.restaurant, color: Color(0xFFE21D2B)),
            title: Text(name),
            subtitle: Text('$price so‘m'),
            trailing: IconButton.filled(
              onPressed: () => add(name, price), icon: const Icon(Icons.add)),
          ));
        }).toList());
      },
    ),
  ]);

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
