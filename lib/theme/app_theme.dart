import 'package:flutter/material.dart';

/// Centralized color palette for ReceiptoX.
/// Reference these constants everywhere instead of hardcoding colors,
/// so the whole app stays visually consistent.
class AppColors {
  static const Color background = Color(0xFF001323);
  static const Color surface = Color(0xFF002744);
  static const Color surfaceLight = Color(0xFF00385C);
  static const Color cardStart = Color(0xFF004466);
  static const Color cardEnd = Color(0xFF001F33);

  static const Color primary = Color(0xFF00E5FF);
  static const Color primaryDark = Color(0xFF0050FF);
  static const Color accentGreen = Color(0xFF00F260);
  static const Color accentBlue = Color(0xFF0575E6);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textMuted = Colors.white38;
  static const Color error = Color(0xFFFF5C5C);

  static const LinearGradient authGradient = LinearGradient(
    colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [accentGreen, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color categoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFFFA726);
      case 'Shopping':
        return const Color(0xFFAB47BC);
      case 'Transport':
        return const Color(0xFF66BB6A);
      case 'Bills':
        return const Color(0xFF42A5F5);
      case 'Entertainment':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  /// Soft "raised" shadow pair that gives cards a floating 3D look
  /// against the dark background (one dark shadow bottom-right,
  /// one faint highlight top-left).
  static List<BoxShadow> raisedShadow({double intensity = 1}) => [
        BoxShadow(
          color: Colors.black.withOpacity(0.45 * intensity),
          offset: const Offset(8, 8),
          blurRadius: 16,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.03 * intensity),
          offset: const Offset(-6, -6),
          blurRadius: 14,
        ),
      ];

  /// Colored glow shadow — use behind cyan/primary accented elements
  /// (buttons, FAB, active cards) to make them feel lit from within.
  static List<BoxShadow> glowShadow(Color color, {double opacity = 0.45}) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 24,
          spreadRadius: 1,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}

class AppTheme {
  static ThemeData get themeData {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accentGreen,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white54,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
