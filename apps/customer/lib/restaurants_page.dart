import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestaurantsPage extends StatefulWidget {
  const RestaurantsPage({super.key});
  @override
  State<RestaurantsPage> createState() => _RestaurantsPageState();
}
class _RestaurantsPageState extends State<RestaurantsPage> {
  String query = '';
  Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    if (!Supabase.instance.isInitialized) return [];
    final result = await Supabase.instance.client.from('restaurants')
      .select('id,name,description,address_line').eq('is_active', true).order('name').limit(100);
    return List<Map<String, dynamic>>.from(result);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Restoranlar')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(onChanged: (v) => setState(() => query = v.toLowerCase()),
        decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
          hintText: 'Restoran qidirish', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRestaurants(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Restoranlarni yuklashda xatolik');
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final rows = snapshot.data!.where((r) =>
            r['name'].toString().toLowerCase().contains(query)).toList();
          if (rows.isEmpty) return const Text('Hozircha faol restoranlar yo‘q.');
          return Column(children: rows.map((r) => Card(child: ListTile(
            leading: const Icon(Icons.storefront, color: Color(0xFFE21D2B)),
            title: Text(r['name'].toString()),
            subtitle: Text((r['description'] ?? r['address_line'] ?? '').toString()),
          ))).toList());
        },
      ),
    ]),
  );
}
