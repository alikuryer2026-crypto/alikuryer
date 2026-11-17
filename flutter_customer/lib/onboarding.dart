import 'package:flutter/material.dart';
import 'reference_design.dart';

/// Local onboarding preview. Phone OTP is not sent until an auth provider is connected.
class AliOnboarding extends StatefulWidget {
  const AliOnboarding({super.key, required this.onFinish});
  final VoidCallback onFinish;
  @override
  State<AliOnboarding> createState() => _AliOnboardingState();
}

class _AliOnboardingState extends State<AliOnboarding> {
  int step = 0;
  String language = '🇺🇿  O‘zbekcha';
  final phone = TextEditingController();
  final code = TextEditingController();

  @override
  void dispose() { phone.dispose(); code.dispose(); super.dispose(); }

  void next() => setState(() => step = (step + 1).clamp(0, 3));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: step == 0 ? AliPalette.red : Colors.white,
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(children: [
        if (step > 0) Align(alignment: Alignment.centerLeft,
          child: IconButton(onPressed: () => setState(() => step--), icon: const Icon(Icons.arrow_back))),
        if (step == 0) const Padding(padding: EdgeInsets.only(top: 14), child: Text('Alikuryer',
          style: TextStyle(color: Colors.white, fontSize: 36, fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900))) else const AliBrandHeader(),
        const SizedBox(height: 26),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          if (step == 0) ...[
            const SizedBox(height: 20),
            Container(height: 235, width: double.infinity,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(colors: [Colors.white.withValues(alpha: .20),
                  Colors.white.withValues(alpha: .04)])),
              child: const Icon(Icons.delivery_dining_rounded, size: 185, color: Colors.white)),
            const SizedBox(height: 30),
            const Text('Hamma narsa\nsiz uchun!', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 34, height: 1.1, fontWeight: FontWeight.w900,
                color: Colors.white)),
            const SizedBox(height: 12),
            const Text('Sevimli taomlaringizni tez, qulay va ishonchli yetkazib beramiz!',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
          ],
          if (step == 1) ...[
            const Text('Tilni tanlang', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text('Ilovadan foydalanish uchun tilni tanlang', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 35),
            for (final lang in ['🇺🇿  O‘zbekcha', '🇷🇺  Русский', '🇬🇧  English', '🇨🇳  中文 (简体)'])
              Padding(padding: const EdgeInsets.only(bottom: 11),
                child: AliSectionCard(child: RadioListTile<String>(
                  contentPadding: EdgeInsets.zero, title: Text(lang),
                  value: lang, groupValue: language,
                  onChanged: (v) => setState(() => language = v ?? language)))),
          ],
          if (step == 2) ...[
            const Icon(Icons.delivery_dining, size: 110, color: AliPalette.red),
            const SizedBox(height: 24),
            const Text('Telefon raqamingizni kiriting', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            const Text('SMS orqali tasdiqlash keyin ulanadi', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 28),
            TextField(controller: phone, keyboardType: TextInputType.phone,
              decoration: const InputDecoration(prefixText: '+998  ', labelText: 'Telefon raqami',
                border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Google va Apple orqali kirish hali ulanmagan.',
              style: TextStyle(color: Colors.black54)),
          ],
          if (step == 3) ...[
            const Icon(Icons.lock_outline, size: 100, color: AliPalette.red),
            const SizedBox(height: 24),
            const Text('Tasdiqlash kodi', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Haqiqiy SMS kodi hali yuborilmaydi.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            TextField(controller: code, keyboardType: TextInputType.number,
              maxLength: 4, textAlign: TextAlign.center,
              decoration: const InputDecoration(labelText: '4 xonali kod (maket)', border: OutlineInputBorder())),
          ],
        ]))),
        const SizedBox(height: 16),
        if (step == 0) const Padding(padding: EdgeInsets.only(bottom: 15),
          child: Text('●  ○  ○  ○', style: TextStyle(color: Colors.white, fontSize: 16))),
        AliRedButton(
          label: step == 0 ? 'Boshlash' : step == 1 ? 'Davom etish' : step == 2 ? 'Ko‘rishni davom ettirish' : 'Ilovani ko‘rish',
          icon: Icons.arrow_forward,
          onPressed: step < 3 ? next : widget.onFinish),
        if (step >= 2) TextButton(onPressed: widget.onFinish,
          child: const Text('Autentifikatsiyasiz sinov rejimida ko‘rish')),
      ]),
    )),
  );
}
