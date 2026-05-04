import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get supabaseUrl => const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://garlimmkvdmhfifqdkgb.supabase.co',
  );
  
  static String get supabaseAnonKey => const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhcmxpbW1rdmRtaGZpZnFka2diIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MTM3OTEsImV4cCI6MjA2NzA4OTc5MX0.5i88_bUQw5OTGxJq0zwV43cDJF9cPt80SnkeB4Lgs6Y',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        pkcePromptType: PkcePromptType.selectAccount,
      ),
    );
  }
}