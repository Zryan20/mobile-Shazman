import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary brand colors
  static const Color primary600 = Color(0xFF406E86);
  static const Color primary700 = Color(0xFF2B5F78);

  // Primary color variations (generated from your base colors)
  static const Color primary100 = Color(0xFFE3F2FF);
  static const Color primary200 = Color(0xFFB8E6FF);
  static const Color primary300 = Color(0xFF85D8FF);
  static const Color primary400 = Color(0xFF42C3FF);
  static const Color primary500 = Color(0xFF0899D9);
  // primary600 is your main brand color
  // primary700 is your darker brand color
  static const Color primary800 = Color(0xFF1E4F63);
  static const Color primary900 = Color(0xFF0F3E50);

  // Secondary colors (complementary teal/green tones)
  static const Color secondary100 = Color(0xFFE6F7F3);
  static const Color secondary200 = Color(0xFFB3E5D8);
  static const Color secondary300 = Color(0xFF80D3BD);
  static const Color secondary400 = Color(0xFF4DC1A2);
  static const Color secondary500 = Color(0xFF1AAF87);
  static const Color secondary600 = Color(0xFF159D6C);
  static const Color secondary700 = Color(0xFF108B51);
  static const Color secondary800 = Color(0xFF0B7936);
  static const Color secondary900 = Color(0xFF06671B);

  // Neutral colors (grays)
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDEEBFF);
  static const Color infoDark = Color(0xFF1E40AF);

  // Learning-specific colors
  static const Color beginner = Color(0xFF22C55E); // Green for A1-A2
  static const Color intermediate = Color(0xFFF59E0B); // Orange for B1-B2
  static const Color advanced = Color(0xFFEF4444); // Red for C1-C2
  static const Color completed = Color(0xFF10B981);
  static const Color locked = Color(0xFF9CA3AF);

  // XP and gamification colors
  static const Color xpGold = Color(0xFFFFC107);
  static const Color streakFire = Color(0xFFFF6B35);
  static const Color starYellow = Color(0xFFFFD700);

  // Light mode colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark mode colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF475569);

  // Legacy text colors (for backward compatibility)
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textTertiary = textTertiaryLight;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Legacy border colors
  static const Color border = borderLight;
  static const Color borderLightLegacy = Color(0xFFF3F4F6);
  static const Color borderDarkLegacy = Color(0xFF374151);

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x66000000);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary600, primary700],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [primary700, primary800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Level-specific color methods
  static Color getLevelColor(int level) {
    switch (level) {
      case 1: // A1
      case 2: // A2
        return beginner;
      case 3: // B1
      case 4: // B2
        return intermediate;
      case 5: // C1
      case 6: // C2
        return advanced;
      default:
        return neutral500;
    }
  }

  static Color getLevelColorLight(int level) {
    return getLevelColor(level).withValues(alpha: 0.1);
  }

  // Adaptive color methods (returns appropriate color based on brightness)
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.dark ? backgroundDark : backgroundLight;
  }

  static Color getSurface(Brightness brightness) {
    return brightness == Brightness.dark ? surfaceDark : surfaceLight;
  }

  static Color getCard(Brightness brightness) {
    return brightness == Brightness.dark ? cardDark : Colors.white;
  }

  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? textPrimaryDark : textPrimaryLight;
  }

  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color getTextTertiary(Brightness brightness) {
    return brightness == Brightness.dark ? textTertiaryDark : textTertiaryLight;
  }

  static Color getBorder(Brightness brightness) {
    return brightness == Brightness.dark ? borderDark : borderLight;
  }

  static LinearGradient getPrimaryGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? primaryGradientDark
        : primaryGradient;
  }

  static LinearGradient getBackgroundGradient(Brightness brightness) {
    return brightness == Brightness.dark
        ? backgroundGradientDark
        : backgroundGradient;
  }

  // Utility methods
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
