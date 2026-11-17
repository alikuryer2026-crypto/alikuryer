import 'package:flutter/material.dart';
import 'reference_design.dart';
import 'map_preview.dart';

/// Additional customer screens matching the approved 16-screen design direction.
/// These are visual flows and intentionally do not simulate real payments or GPS.
class AliScreens extends StatelessWidget {
  const AliScreens({super.key, required this.onOpen});
  final void Function(String) onOpen;
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class AliPage extends StatelessWidget {
  const AliPage({super.key, required this.title, required this.children, this.subtitle});
  final String title;
  final String? subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AliPalette.canvas,
    appBar: AppBar(backgroundColor: Colors.white, title: const AliBrandHeader()),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 15, 16, 35), children: [
      Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AliPalette.ink)),
      if (subtitle != null) ...[const SizedBox(height: 5), Text(subtitle!, style: const TextStyle(color: Colors.black54))],
      const SizedBox(height: 18),
      ...children,
    ]),
  );
}

class AliActionTile extends StatelessWidget {
  const AliActionTile({super.key, required this.icon, required this.title, this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: AliSectionCard(padding: EdgeInsets.zero, child: ListTile(
      onTap: onTap, leading: CircleAvatar(backgroundColor: AliPalette.softRed,
        child: Icon(icon, color: AliPalette.red)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right),
    )),
  );
}

class AliHubScreen extends StatelessWidget {
  const AliHubScreen({super.key, required this.open});
  final void Function(String) open;
  @override
  Widget build(BuildContext context) => AliPage(
    title: 'Mijoz kabineti', subtitle: 'Profilingiz va xizmatlar',
    children: [
      const AliSectionCard(child: Row(children: [
        CircleAvatar(radius: 29, backgroundColor: AliPalette.softRed,
          child: Icon(Icons.person, color: AliPalette.red, size: 32)),
        SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Alikuryer mijoz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text('Shaxsiy kabinetingiz', style: TextStyle(color: Colors.black54)),
        ])),
      ])),
      const SizedBox(height: 18),
      AliActionTile(icon: Icons.person_outline, title: 'Profilni tahrirlash', onTap: () => open('edit')),
      AliActionTile(icon: Icons.location_on_outlined, title: 'Manzillarim', onTap: () => open('address')),
      AliActionTile(icon: Icons.favorite_outline, title: 'Sevimlilar', onTap: () => open('favorites')),
      AliActionTile(icon: Icons.credit_card, title: 'To‘lov usullari', onTap: () => open('payment')),
      AliActionTile(icon: Icons.local_shipping_outlined, title: 'Buyurtmani kuzatish', onTap: () => open('tracking')),
      AliActionTile(icon: Icons.support_agent, title: 'Yordam markazi', onTap: () => open('support')),
    ],
  );
}

class AliEditProfileScreen extends StatefulWidget {
  const AliEditProfileScreen({super.key});
  @override
  State<AliEditProfileScreen> createState() => _AliEditProfileScreenState();
}
class _AliEditProfileScreenState extends State<AliEditProfileScreen> {
  final name = TextEditingController();
  final surname = TextEditingController();
  final email = TextEditingController();
  @override
  void dispose() { name.dispose(); surname.dispose(); email.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AliPage(title: 'Profilni tahrirlash', children: [
    const Center(child: CircleAvatar(radius: 46, backgroundColor: AliPalette.softRed,
      child: Icon(Icons.person, color: AliPalette.red, size: 51))),
    const SizedBox(height: 24),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Ism', border: OutlineInputBorder())),
    const SizedBox(height: 12),
    TextField(controller: surname, decoration: const InputDecoration(labelText: 'Familiya', border: OutlineInputBorder())),
    const SizedBox(height: 12),
    TextField(controller: email, keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(labelText: 'Elektron pochta', border: OutlineInputBorder())),
    const SizedBox(height: 18),
    AliRedButton(label: 'O‘zgarishlarni saqlash', icon: Icons.check,
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilni serverga saqlash keyingi bosqichda ulanadi.')))),
  ]);
}

class AliAddressScreen extends StatefulWidget {
  const AliAddressScreen({super.key});
  @override
  State<AliAddressScreen> createState() => _AliAddressScreenState();
}
class _AliAddressScreenState extends State<AliAddressScreen> {
  final address = TextEditingController();
  @override
  void dispose() { address.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AliPage(title: 'Manzilni belgilash', subtitle: 'Yetkazib berish manzilini kiriting', children: [
    const AliMapPreview(height: 230),
    const SizedBox(height: 20),
    TextField(controller: address, maxLines: 2, decoration: const InputDecoration(
      labelText: 'Ko‘cha, uy va xonadon', border: OutlineInputBorder())),
    const SizedBox(height: 15),
    AliRedButton(label: 'Manzilni saqlash', onPressed: () =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Xarita va manzillar bazasi hali ulanmagan.')))),
  ]);
}

class AliPaymentScreen extends StatefulWidget {
  const AliPaymentScreen({super.key});
  @override
  State<AliPaymentScreen> createState() => _AliPaymentScreenState();
}
class _AliPaymentScreenState extends State<AliPaymentScreen> {
  String method = 'cash';
  @override
  Widget build(BuildContext context) => AliPage(title: 'To‘lov usullari', subtitle: 'Hozircha faqat interfeys', children: [
    for (final option in [
      ('card', 'Karta orqali to‘lov', Icons.credit_card),
      ('click', 'Click', Icons.account_balance_wallet_outlined),
      ('payme', 'Payme', Icons.payments_outlined),
      ('cash', 'Naqd pul', Icons.money),
    ])
      Padding(padding: const EdgeInsets.only(bottom: 9),
        child: AliSectionCard(child: RadioListTile<String>(
          value: option.$1, groupValue: method, onChanged: (v) => setState(() => method = v ?? method),
          title: Text(option.$2), secondary: Icon(option.$3, color: AliPalette.red)))),
    const SizedBox(height: 10),
    AliRedButton(label: 'To‘lov usulini tanlash', onPressed: () =>
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('To‘lov integratsiyasi keyingi bosqichda ulanadi.')))),
  ]);
}

class AliTrackingScreen extends StatelessWidget {
  const AliTrackingScreen({super.key, this.accepted = false});
  final bool accepted;
  @override
  Widget build(BuildContext context) => AliPage(
    title: accepted ? 'Buyurtmangiz qabul qilindi' : 'Buyurtmani kuzatish',
    subtitle: 'Jonli kuzatuv Supabase va GPS ulangach ishlaydi',
    children: [
      const AliMapPreview(height: 245, showCourier: true),
      const SizedBox(height: 18),
      const AliActionTile(icon: Icons.restaurant, title: 'Restoran', subtitle: 'Buyurtma ma’lumotlari keyin ulanadi'),
      const AliActionTile(icon: Icons.delivery_dining, title: 'Kuryer', subtitle: 'Kuryer tayinlanmagan'),
      const AliActionTile(icon: Icons.support_agent, title: 'Yordam', subtitle: 'Yordam xizmati keyin ulanadi'),
    ],
  );
}

class AliFavoritesScreen extends StatelessWidget {
  const AliFavoritesScreen({super.key, required this.items});
  final List<String> items;
  @override
  Widget build(BuildContext context) => AliPage(title: 'Sevimlilar',
    subtitle: 'Siz saqlagan taomlar',
    children: items.isEmpty
      ? [const AliSectionCard(child: Column(children: [
          Icon(Icons.favorite_border, color: AliPalette.red, size: 56),
          SizedBox(height: 12),
          Text('Sevimlilar ro‘yxati hozircha bo‘sh'),
          SizedBox(height: 6),
          Text('Taom kartasidagi yurakchani bosib saqlang.',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        ]))]
      : items.map((item) => AliActionTile(
          icon: Icons.favorite, title: item,
          subtitle: 'Saqlangan taom',
        )).toList(),
  );
}

class AliSupportScreen extends StatelessWidget {
  const AliSupportScreen({super.key});
  @override
  Widget build(BuildContext context) => const AliPage(title: 'Yordam markazi',
    children: [
      AliActionTile(icon: Icons.help_outline, title: 'Ko‘p so‘raladigan savollar'),
      AliActionTile(icon: Icons.chat_outlined, title: 'Operator bilan bog‘lanish',
        subtitle: 'Chat xizmati keyin ulanadi'),
      AliActionTile(icon: Icons.phone_outlined, title: 'Qo‘ng‘iroq qilish',
        subtitle: 'Rasmiy yordam raqami keyin qo‘shiladi'),
    ]);
}

class AliWalletScreen extends StatelessWidget {
  const AliWalletScreen({super.key});
  @override
  Widget build(BuildContext context) => const AliPage(title: 'Mening hamyonim',
    subtitle: 'Bonus va to‘lovlar xizmati keyingi bosqichda ulanadi',
    children: [
      AliSectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonus hisobi', style: TextStyle(color: Colors.black54)),
        SizedBox(height: 8), Text('Hali faol emas', style: TextStyle(
          fontSize: 25, fontWeight: FontWeight.w900, color: AliPalette.red)),
        SizedBox(height: 8), Text('Balans va bonuslar hozircha hisoblanmaydi.'),
      ])),
    ]);
}
