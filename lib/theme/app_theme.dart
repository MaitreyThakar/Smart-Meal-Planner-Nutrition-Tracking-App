import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF00C896);
  static const Color primaryDark = Color(0xFF00A67E);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFB347);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF00E676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A2535), Color(0xFF0F1923)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Background
  static const Color bgDark = Color(0xFF0F1923);
  static const Color bgCard = Color(0xFF1A2535);
  static const Color bgCardLight = Color(0xFF1E2D40);
  static const Color surface = Color(0xFF243347);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8FA3B1);
  static const Color textMuted = Color(0xFF4A6274);

  // Meal type colors
  static const Color breakfastColor = Color(0xFFFF9A3C);
  static const Color lunchColor = Color(0xFF00C896);
  static const Color dinnerColor = Color(0xFF7C4DFF);
  static const Color snacksColor = Color(0xFFFF6B6B);

  static Color mealTypeColor(String type) {
    switch (type) {
      case 'Breakfast': return breakfastColor;
      case 'Lunch': return lunchColor;
      case 'Dinner': return dinnerColor;
      case 'Snacks': return snacksColor;
      default: return primary;
    }
  }

  static IconData mealTypeIcon(String type) {
    switch (type) {
      case 'Breakfast': return Icons.wb_sunny_rounded;
      case 'Lunch': return Icons.lunch_dining_rounded;
      case 'Dinner': return Icons.nights_stay_rounded;
      case 'Snacks': return Icons.cookie_rounded;
      default: return Icons.restaurant_rounded;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: surface, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          elevation: 8,
          shadowColor: primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A121A),
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
      dividerColor: surface,
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Colors.transparent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

