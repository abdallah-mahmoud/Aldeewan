import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Base brand colors
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF4338CA); // Indigo 700
  static const Color _lightOnSurface = Color(0xFF1E293B); // Slate 800

  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color _darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color _darkPrimary = Color(0xFF818CF8); // Indigo 400
  static const Color _darkOnSurface = Color(0xFFF1F5F9); // Slate 100

  static const Color _brandRed = Color(0xFFEF4444);

  // Semantic colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  static ThemeData get light {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightPrimary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        error: _brandRed,
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: false),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _lightBackground,
        foregroundColor: _lightOnSurface,
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurface,
        selectedColor: _lightPrimary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(color: _lightOnSurface),
        secondaryLabelStyle: const TextStyle(color: _lightPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: _lightPrimary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _lightPrimary);
          }
          return IconThemeData(color: _lightOnSurface.withValues(alpha: 0.6));
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: _lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: Colors.black,
        secondary: _darkPrimary,
        onSecondary: Colors.black,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        error: _brandRed,
        onError: Colors.white,
      ),
      textTheme: _buildTextTheme(base.textTheme, isDark: true),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurface,
        selectedColor: _darkPrimary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: _darkOnSurface),
        secondaryLabelStyle: const TextStyle(color: _darkPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: _darkPrimary.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _darkPrimary);
          }
          return IconThemeData(color: _darkOnSurface.withValues(alpha: 0.6));
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, {required bool isDark}) {
    final onSurface = isDark ? _darkOnSurface : _lightOnSurface;
    final fontTheme = GoogleFonts.cairoTextTheme(base);
    
    return fontTheme.copyWith(
      headlineLarge: fontTheme.headlineLarge?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
      headlineMedium: fontTheme.headlineMedium?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
      titleMedium: fontTheme.titleMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
      bodyLarge: fontTheme.bodyLarge?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
      bodyMedium: fontTheme.bodyMedium?.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
      bodySmall: fontTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: onSurface.withValues(alpha: 0.7),
          ),
    );
  }
}
