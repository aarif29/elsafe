import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService instance = ThemeService._();
  ThemeService._();

  static const _key = 'theme_mode';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.dark);

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    themeMode.value = saved == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
  }

  static ThemeData dark() => ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00C6FF),
          surface: Colors.grey[900]!,
          onSurface: Colors.white,
          onSurfaceVariant: Colors.grey[400]!,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardColor: Colors.grey[800],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey[600],
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0072FF),
            foregroundColor: Colors.white,
          ),
        ),
        dividerColor: Colors.grey[800],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        ),
      );

  static ThemeData light() => ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00C6FF),
          surface: Colors.white,
          onSurface: Colors.black87,
          onSurfaceVariant: Colors.grey[600]!,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shadowColor: Colors.black12,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: Colors.grey[500],
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0072FF),
            foregroundColor: Colors.white,
          ),
        ),
        dividerColor: Colors.grey[300],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
        ),
      );
}

extension AppThemeExt on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor => isDark ? Colors.black : const Color(0xFFF2F4F7);
  Color get surfaceColor => isDark ? Colors.grey[900]! : Colors.white;
  Color get cardColor => isDark ? Colors.grey[800]! : Colors.grey[200]!;
  Color get inputFillColor => isDark ? Colors.grey[850]! : Colors.grey[100]!;
  Color get subtleSurface => isDark ? Colors.grey[850]! : Colors.grey[100]!;

  Color get borderColor => isDark ? Colors.grey[800]! : Colors.grey[300]!;
  Color get subtleBorder => isDark ? Colors.grey[700]! : Colors.grey[200]!;

  Color get textPrimary => isDark ? Colors.white : Colors.black87;
  Color get textSecondary => isDark ? Colors.grey[400]! : Colors.grey[700]!;
  Color get textHint => isDark ? Colors.grey[500]! : Colors.grey[500]!;
  Color get textDisabled => isDark ? Colors.grey[600]! : Colors.grey[400]!;

  Color get segmentBg => isDark ? Colors.grey[850]! : Colors.grey[200]!;
  Color get skeletonBase => isDark ? Colors.grey[700]! : Colors.grey[300]!;
}
