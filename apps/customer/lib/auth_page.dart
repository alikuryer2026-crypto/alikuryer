import 'supabase_state.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}
class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? message;
  Future<void> submit({required bool signup}) async {
    if (!legacySupabaseReady) {
      setState(() => message = 'Supabase ulanmagan');
      return;
    }
    setState(() { busy = true; message = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (signup) {
        await auth.signUp(email: email.text.trim(), password: password.text);
        setState(() => message = 'Ro‘yxatdan o‘tish so‘rovi yuborildi. Emailni tekshiring.');
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
        if (mounted) Navigator.pop(context, true);
      }
    } on AuthException catch (e) {
      setState(() => message = e.message);
    } catch (_) {
      setState(() => message = 'Ulanishda xatolik. Qayta urinib ko‘ring.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Alikuryer — Kirish')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const Icon(Icons.delivery_dining, size: 80, color: Color(0xFFE21D2B)),
      const SizedBox(height: 24),
      TextField(controller: email, keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: true,
        decoration: const InputDecoration(labelText: 'Parol (kamida 6 belgi)', border: OutlineInputBorder())),
      const SizedBox(height: 20),
      FilledButton(onPressed: busy ? null : () => submit(signup: false), child: const Text('Kirish')),
      TextButton(onPressed: busy ? null : () => submit(signup: true), child: const Text('Ro‘yxatdan o‘tish')),
      if (message != null) Padding(padding: const EdgeInsets.all(12), child: Text(message!)),
      const SizedBox(height: 12),
      const Text('Google va telefon orqali kirish alohida sozlangandan so‘ng qo‘shiladi.'),
    ]),
  );
}
