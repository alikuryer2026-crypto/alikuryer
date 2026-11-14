import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isEmpty || key.isEmpty) {
    throw StateError('Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEY');
  }
  await Supabase.initialize(url: url, anonKey: key);
  runApp(const AlikuryerApp());
}

class AlikuryerApp extends StatelessWidget {
  const AlikuryerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alikuryer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE21D2B)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Alikuryer', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
