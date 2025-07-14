import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://garlimmkvdmhfifqdkgb.supabase.co'; // Ganti dengan URL proyek Anda
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhcmxpbW1rdmRtaGZpZnFka2diIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MTM3OTEsImV4cCI6MjA2NzA4OTc5MX0.5i88_bUQw5OTGxJq0zwV43cDJF9cPt80SnkeB4Lgs6Y'; // Ganti dengan anon key Anda

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}