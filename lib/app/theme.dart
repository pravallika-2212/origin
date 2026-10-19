import 'package:flutter/material.dart';
import 'package:origin/core/fonts.dart';

class OriginColors {
  static const ivory = Color(0xFFF8F6EF);
  static const ivoryLight = Color(0xFFFFFDF8);
  static const ivoryDark = Color(0xFFEFE9DA);
  static const gold = Color(0xFFD4AF7C);
  static const goldLight = Color(0xFFF1DCAE);
  static const goldDark = Color(0xFF9A7440);
  static const royalBronze = Color(0xFF5B4120);
  static const sage = Color(0xFF8CA68B);
  static const sageLight = Color(0xFFDFE6D9);
  static const blush = Color(0xFFEBC9C1);
  static const blushLight = Color(0xFFF6DCD5);
  static const lavender = Color(0xFFC9B8E4);
  static const lavenderLight = Color(0xFFE9E0F3);
  static const ink = Color(0xFF2E2E2E);
  static const inkLight = Color(0xFF5C5448);
  static const inkMuted = Color(0xFF7A7060);
  static const cardBorder = Color(0x59D4AF7C); // rgba(212,175,124, 0.35)
}

ThemeData originTheme() {
  final baseTextTheme = GoogleFonts.montserratTextTheme();
  
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: OriginColors.ivory,
    colorScheme: ColorScheme.fromSeed(
      seedColor: OriginColors.goldDark,
      primary: OriginColors.goldDark,
      secondary: OriginColors.gold,
      surface: OriginColors.ivory,
      onPrimary: Colors.white,
      onSurface: OriginColors.ink,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        letterSpacing: 6,
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w400,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        letterSpacing: 4,
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        letterSpacing: 2,
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        color: OriginColors.royalBronze,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        color: OriginColors.ink,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.montserrat(
        color: OriginColors.ink,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.montserrat(
        color: OriginColors.ink,
        fontSize: 15,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.montserrat(
        color: OriginColors.inkLight,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.montserrat(
        color: OriginColors.inkMuted,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.montserrat(
        letterSpacing: 2.0,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: OriginColors.cardBorder,
      thickness: 1,
    ),
  );
}
