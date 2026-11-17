import 'supabase_state.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});
  @override
  State<AddressesPage> createState() => _AddressesPageState();
}
class _AddressesPageState extends State<AddressesPage> {
  final label = TextEditingController();
  final address = TextEditingController();
  bool saving = false;
  Future<void> save() async {
    if (address.text.trim().isEmpty) return;
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;
    setState(() => saving = true);
    try {
      await client.from('addresses').insert({
        'user_id': user.id,
        'label': label.text.trim(),
        'address_line': address.text.trim(),
      });
      if (mounted) { label.clear(); address.clear(); setState(() {}); }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manzilni saqlashda xatolik')));
    } finally { if (mounted) setState(() => saving = false); }
  }
  @override
  void dispose() { label.dispose(); address.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!legacySupabaseReady || Supabase.instance.client.auth.currentUser == null) {
      return Scaffold(appBar: AppBar(title: const Text('Manzillar')),
        body: const Center(child: Text('Manzillarni saqlash uchun tizimga kiring.')));
    }
    final client = Supabase.instance.client;
    return Scaffold(appBar: AppBar(title: const Text('Mening manzillarim')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: label, decoration: const InputDecoration(labelText: 'Nomi (Uy, Ish)')),
        TextField(controller: address, decoration: const InputDecoration(labelText: 'To‘liq manzil')),
        const SizedBox(height: 12),
        FilledButton(onPressed: saving ? null : save, child: const Text('Manzilni saqlash')),
        const SizedBox(height: 18),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: client.from('addresses').select('id,label,address_line')
            .eq('user_id', client.auth.currentUser!.id).order('created_at', ascending: false),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('Manzillarni yuklab bo‘lmadi');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            return Column(children: snapshot.data!.map((a) => ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text((a['label'] ?? 'Manzil').toString()),
              subtitle: Text(a['address_line'].toString()),
            )).toList());
          },
        ),
      ]));
  }
}
