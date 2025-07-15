import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'Screen/splashscreen.dart';
import 'profil/loginscreen.dart';
import 'Screen/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://garlimmkvdmhfifqdkgb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdhcmxpbW1rdmRtaGZpZnFka2diIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE1MTM3OTEsImV4cCI6MjA2NzA4OTc5MX0.5i88_bUQw5OTGxJq0zwV43cDJF9cPt80SnkeB4Lgs6Y',
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;
  bool _isRedirecting = false;
  
  // GlobalKey untuk Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Delay untuk memastikan Navigator sudah ter-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () => _redirect());
    });
  }

  void _redirect() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    try {
      // Delay awal untuk memastikan aplikasi sudah ter-load
      await Future.delayed(const Duration(milliseconds: 100));

      // Cek URL saat ini
      final uri = Uri.base;
      debugPrint('🌐 [DEBUG] Current URL: $uri');
      debugPrint('🌐 [DEBUG] URL Fragment: ${uri.fragment}');
      debugPrint('🌐 [DEBUG] URL Query: ${uri.query}');

      // Cek apakah ada access_token di URL fragment (OAuth callback)
      bool hasAuthCallback = uri.fragment.contains('access_token') || 
                            uri.fragment.contains('code=') ||
                            uri.query.contains('code=');

      if (hasAuthCallback) {
        debugPrint('🔑 [DEBUG] OAuth callback detected in URL!');
        debugPrint('🔑 [DEBUG] Waiting for Supabase to process session...');
        
        // Tunggu lebih lama untuk session ter-update setelah OAuth callback
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Cek session beberapa kali dengan interval
        Session? session;
        for (int i = 0; i < 5; i++) {
          session = Supabase.instance.client.auth.currentSession;
          debugPrint('🔄 [DEBUG] Session check attempt ${i + 1}: ${session?.user?.email}');
          
          if (session != null) {
            debugPrint('✅ [DEBUG] Session found after OAuth callback!');
            break;
          }
          
          if (i < 4) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        }
      }

      // Cek session final
      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('🔍 [DEBUG] Final Session Check: ${session?.user?.email}');
      debugPrint('🔍 [DEBUG] Session Access Token: ${session?.accessToken != null ? "Present" : "Null"}');
      debugPrint('🔍 [DEBUG] Session Expires At: ${session?.expiresAt}');

      // Gunakan NavigatorState dari GlobalKey
      final navigatorState = _navigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint('❌ [DEBUG] Navigator not ready yet, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
        _isRedirecting = false;
        _redirect();
        return;
      }

      if (session != null) {
        debugPrint('✅ [DEBUG] Valid session found, redirecting to dashboard');
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/dashboard') {
          navigatorState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
              settings: const RouteSettings(name: '/dashboard'),
            ),
            (route) => false,
          );
        }
      } else {
        debugPrint('🔒 [DEBUG] No valid session found, redirecting to login');
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/login') {
          navigatorState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
              settings: const RouteSettings(name: '/login'),
            ),
            (route) => false,
          );
        }
      }

      // Setup listener untuk perubahan auth state
      _setupAuthListener();

    } catch (e) {
      debugPrint('❌ [DEBUG] Error in _redirect: $e');
    } finally {
      _isRedirecting = false;
    }
  }

  void _setupAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (_isRedirecting) return;
      
      final event = data.event;
      final session = data.session;
      
      debugPrint('⚡ [DEBUG] Auth Event: $event');
      debugPrint('⚡ [DEBUG] Session User: ${session?.user?.email}');
      debugPrint('⚡ [DEBUG] Event Timestamp: ${DateTime.now()}');

      final navigatorState = _navigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint('❌ [DEBUG] Navigator not available for auth event');
        return;
      }

      if (event == AuthChangeEvent.signedIn && session != null) {
        debugPrint('🎉 [DEBUG] User signed in successfully!');
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/dashboard') {
          _isRedirecting = true;
          navigatorState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
              settings: const RouteSettings(name: '/dashboard'),
            ),
            (route) => false,
          ).then((_) {
            _isRedirecting = false;
          });
        }
      } else if (event == AuthChangeEvent.signedOut) {
        debugPrint('👋 [DEBUG] User signed out');
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/login') {
          _isRedirecting = true;
          navigatorState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
              settings: const RouteSettings(name: '/login'),
            ),
            (route) => false,
          ).then((_) {
            _isRedirecting = false;
          });
        }
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        debugPrint('🔄 [DEBUG] Token refreshed');
      }
    }, onError: (error) {
      debugPrint('❌ [DEBUG] Auth Error: $error');
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey, // Tambahkan GlobalKey di sini
      title: 'Elsafe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0072FF),
          secondary: Color(0xFF00C6FF),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0072FF),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const ElsafeSplashScreen(),
    );
  }
}