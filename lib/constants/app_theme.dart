import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF4A5FF7);
  static const Color primaryLight = Color(0xFF6B7BFF);
  static const Color primaryDark = Color(0xFF3347D4);
  
  // Secondary Colors
  static const Color secondaryRed = Color(0xFFFF6B6B);
  static const Color secondaryOrange = Color(0xFFFF8C42);
  static const Color secondaryYellow = Color(0xFFFFD93D);
  static const Color secondaryGreen = Color(0xFF6BCF7F);
  
  // Neutral Colors - Light Mode
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFF1A1D29);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color surfaceVariantDark = Color(0xFF21262D);
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textTertiaryDark = Color(0xFF6E7681);
  
  // Onboarding Colors
  static const Color onboardingRed = Color(0xFFFF6B6B);
  static const Color onboardingYellow = Color(0xFFFFD166);
  static const Color onboardingBlue = Color(0xFF3A86FF);

  // Additional Colors
  static const Color purpleBackground = Color(0xFF6B46C1); // Purple background for splash
  static const Color white = Color(0xFFFFFFFF); // White color
  
  // Text Styles
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle displayMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );
  
  static TextStyle headingLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600, // SemiBold
    color: textPrimary,
  );
  
  static TextStyle headingMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: textPrimary,
  );
  
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );
  
  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );

  static TextStyle titleSmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );
  
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );
  
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500, // Medium
    color: textPrimary,
  );
  
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: surface,
  );
  
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      primaryContainer: primaryLight,
      onPrimary: surface,
      secondary: secondaryRed,
      secondaryContainer: secondaryYellow,
      onSecondary: textPrimary,
      tertiary: secondaryGreen,
      surface: surface,
      onSurface: textPrimary,
      error: secondaryRed,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 2,
      titleTextStyle: headingMedium,
      centerTitle: false,
      shadowColor: Colors.black12,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: surface,
        textStyle: buttonText,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        textStyle: buttonText.copyWith(color: primaryBlue),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surface,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: const CardThemeData(
      color: surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryBlue,
      unselectedLabelColor: textSecondary,
      labelStyle: labelLarge.copyWith(color: primaryBlue),
      unselectedLabelStyle: labelLarge.copyWith(color: textSecondary),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryBlue,
            width: 3,
          ),
        ),
      ),
    ),
  );
  
  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      primaryContainer: primaryLight,
      onPrimary: surfaceDark,
      secondary: secondaryRed,
      secondaryContainer: secondaryYellow,
      onSecondary: textPrimaryDark,
      tertiary: secondaryGreen,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      error: secondaryRed,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 2,
      titleTextStyle: headingMedium.copyWith(color: textPrimaryDark),
      centerTitle: false,
      shadowColor: Colors.black26,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textPrimaryDark,
        textStyle: buttonText.copyWith(color: textPrimaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        textStyle: buttonText.copyWith(color: primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceVariantDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: surfaceVariantDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: surfaceVariantDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: const CardThemeData(
      color: surfaceDark,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryDark,
      labelStyle: labelLarge.copyWith(color: primaryLight),
      unselectedLabelStyle: labelLarge.copyWith(color: textSecondaryDark),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: primaryLight,
            width: 3,
          ),
        ),
      ),
    ),
  );
} 