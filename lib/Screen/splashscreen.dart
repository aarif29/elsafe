import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elsafe/Screen/loginscreen.dart';

void main() {
  runApp(const ElsafeApp());
}

class ElsafeApp extends StatelessWidget {
  const ElsafeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ELSAFE',
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

class ElsafeSplashScreen extends StatefulWidget {
  const ElsafeSplashScreen({Key? key}) : super(key: key);

  @override
  State<ElsafeSplashScreen> createState() => _ElsafeSplashScreenState();
}

class _ElsafeSplashScreenState extends State<ElsafeSplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _animationController.forward();

    // Auto navigate to login after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: const Icon(
                          Icons.flash_on,
                          size: 72,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App Name
                      const Text(
                        'ELSAFE',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Text(
                        'Menjaga Energi, Melindungi Nyawa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0072FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}