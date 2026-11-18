import 'package:supabase_flutter/supabase_flutter.dart';

/// Public client configuration only. Never put a service_role or secret key here.
/// Override at build time with --dart-define=SUPABASE_URL=... and
/// --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class AliBackend {
  static const url = String.fromEnvironment('SUPABASE_URL',
      defaultValue: 'https://bjgffagonedmvasamtlo.supabase.co');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_sGmCLa3T1L-_ha1Ga6oBdA_yYiCiMKJ');

  static bool ready = false;
  static String? startupError;

  static Future<void> initialize() async {
    if (url.isEmpty || publishableKey.isEmpty) {
      startupError = 'Supabase URL yoki publishable key kiritilmagan';
      return;
    }
    try {
      await Supabase.initialize(url: url, anonKey: publishableKey);
      ready = true;
    } catch (error) {
      startupError = error.toString();
    }
  }

  static SupabaseClient get client {
    if (!ready) throw StateError(startupError ?? 'Supabase ulanmagan');
    return Supabase.instance.client;
  }

  static bool get signedIn => ready && client.auth.currentUser != null;

  /// A read-only connectivity/RLS check. No customer data is modified.
  static Future<String> checkRestaurants() async {
    if (!ready) return startupError ?? 'Supabase sozlanmagan';
    try {
      await client.from('restaurants').select('id').limit(1);
      return 'Supabase REST so‘rovi bajarildi (restaurants).';
    } catch (error) {
      return 'Supabase so‘rovida xato: $error';
    }
  }

  static Future<void> sendPhoneOtp(String phone) async {
    if (!ready) throw StateError('Supabase ulanmagan');
    await client.auth.signInWithOtp(phone: phone);
  }

  static Future<void> verifyPhoneOtp(String phone, String token) async {
    if (!ready) throw StateError('Supabase ulanmagan');
    await client.auth.verifyOTP(
      phone: phone, token: token, type: OtpType.sms,
    );
    if (!signedIn) throw StateError('Sessiya yaratilmagan');
  }
}
