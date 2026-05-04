import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Screen/splashscreen.dart';
import 'profil/loginscreen.dart';
import 'Screen/main_shell.dart';
import 'Screen/ulp_selection_screen.dart';
import 'config/supabase_config.dart';
import 'config/new_password.dart';
import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
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
  
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _setupAuthListener(); // pasang listener DULU agar passwordRecovery event tidak terlewat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () => _redirect());
    });
  }

  /// Setelah login berhasil, cek apakah user sudah memiliki ULP.
  /// Jika belum → arahkan ke UlpSelectionScreen.
  /// Jika sudah → arahkan ke MainShell.
  Future<void> _navigateAfterLogin(NavigatorState nav, String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('ulp')
          .eq('id', userId)
          .maybeSingle();

      final ulp = profile?['ulp'] as String?;
      final hasUlp = ulp != null && ulp.isNotEmpty;

      debugPrint('🏢 [DEBUG] ULP check: ${hasUlp ? ulp : "belum disetel"}');

      final currentRoute = ModalRoute.of(nav.context)?.settings.name;

      if (!hasUlp && currentRoute != '/ulp-selection') {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const UlpSelectionScreen(),
            settings: const RouteSettings(name: '/ulp-selection'),
          ),
          (route) => false,
        );
      } else if (hasUlp && currentRoute != '/shell') {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainShell(),
            settings: const RouteSettings(name: '/shell'),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Error cek ULP: $e');
      // Fallback ke MainShell jika ada error
      nav.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShell(),
          settings: const RouteSettings(name: '/shell'),
        ),
        (route) => false,
      );
    }
  }

  void _redirect() async {
    if (_isRedirecting) return;
    _isRedirecting = true;

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final uri = Uri.base;
      debugPrint('🌐 [DEBUG] Current URL: $uri');
      debugPrint('🌐 [DEBUG] URL Fragment: ${uri.fragment}');
      debugPrint('🌐 [DEBUG] URL Query: ${uri.query}');

      bool hasAuthCallback = uri.fragment.contains('access_token') ||
                            uri.fragment.contains('code=') ||
                            uri.query.contains('code=');
      bool isPasswordRecovery = uri.fragment.contains('type=recovery') ||
                                uri.query.contains('type=recovery');

      if (hasAuthCallback) {
        debugPrint('🔑 [DEBUG] OAuth callback detected in URL!');
        debugPrint('🔑 [DEBUG] Is password recovery: $isPasswordRecovery');

        // Jika ada PKCE code di URL, tukar secara eksplisit dengan session.
        if (uri.query.contains('code=')) {
          debugPrint('🔑 [DEBUG] PKCE code detected, exchanging for session...');
          try {
            await Supabase.instance.client.auth.exchangeCodeForSession(uri.toString());
            debugPrint('✅ [DEBUG] exchangeCodeForSession succeeded');
          } catch (e) {
            debugPrint('❌ [DEBUG] exchangeCodeForSession failed: $e');
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        Session? session;
        for (int i = 0; i < 5; i++) {
          session = Supabase.instance.client.auth.currentSession;
          debugPrint('🔄 [DEBUG] Session check attempt ${i + 1}: ${session?.user?.email}');
          if (session != null) {
            debugPrint('✅ [DEBUG] Session found after OAuth callback!');
            break;
          }
          if (i < 4) await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final session = Supabase.instance.client.auth.currentSession;
      debugPrint('🔍 [DEBUG] Final Session Check: ${session?.user?.email}');
      debugPrint('🔍 [DEBUG] Session Access Token: ${session?.accessToken != null ? "Present" : "Null"}');
      debugPrint('🔍 [DEBUG] Session Expires At: ${session?.expiresAt}');

      final navigatorState = _navigatorKey.currentState;
      if (navigatorState == null) {
        debugPrint('❌ [DEBUG] Navigator not ready yet, retrying...');
        await Future.delayed(const Duration(milliseconds: 500));
        _isRedirecting = false;
        _redirect();
        return;
      }

      if (session != null && isPasswordRecovery) {
        debugPrint('🔑 [DEBUG] Password recovery session, redirecting to NewPasswordPage');
        navigatorState.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NewPasswordPage(),
            settings: const RouteSettings(name: '/new-password'),
          ),
          (route) => false,
        );
      } else if (session != null) {
        debugPrint('✅ [DEBUG] Valid session found, checking ULP...');
        await ThemeService.instance.loadTheme();
        await _navigateAfterLogin(navigatorState, session.user.id);
      } else if (!hasAuthCallback) {
        // Hanya redirect ke login jika tidak ada OAuth code di URL.
        // Jika ada code, biarkan auth listener yang handle setelah PKCE exchange selesai.
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
      } else {
        debugPrint('⏳ [DEBUG] OAuth code detected, waiting for auth listener to handle signedIn...');
      }

    } catch (e) {
      debugPrint('❌ [DEBUG] Error in _redirect: $e');
    } finally {
      _isRedirecting = false;
    }
  }

  void _setupAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (_isRedirecting && data.event != AuthChangeEvent.signedIn) return;
      
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
        // Jika ini recovery flow, biarkan passwordRecovery event yang handle navigasi
        final uri = Uri.base;
        final isRecovery = uri.fragment.contains('type=recovery') ||
                           uri.query.contains('type=recovery');
        if (isRecovery) {
          debugPrint('🔑 [DEBUG] signedIn event diabaikan — ini recovery flow, tunggu passwordRecovery event');
          return;
        }
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/shell' && currentRoute != '/ulp-selection') {
          _isRedirecting = true;
          ThemeService.instance.loadTheme().then((_) async {
            await _navigateAfterLogin(navigatorState, session.user.id);
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
      } else if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint('🔑 [DEBUG] Password recovery event received');
        final currentRoute = ModalRoute.of(navigatorState.context)?.settings.name;
        if (currentRoute != '/new-password') {
          _isRedirecting = true;
          navigatorState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const NewPasswordPage(),
              settings: const RouteSettings(name: '/new-password'),
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          title: 'Elsafe App',
          debugShowCheckedModeBanner: false,
          theme: ThemeService.light(),
          darkTheme: ThemeService.dark(),
          themeMode: mode,
          home: const ElsafeSplashScreen(),
        );
      },
    );
  }
}