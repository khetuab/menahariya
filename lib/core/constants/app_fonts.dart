// lib/core/constants/app_fonts.dart

import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  // Font Families
  static const String fontFamilyPrimary = 'Poppins';
  static const String fontFamilySecondary = 'Roboto';
  static const String fontFamilyAmharic = 'NotoSansEthiopic'; // For Amharic support

  // Font Weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Font Sizes
  static const double size10 = 10.0;
  static const double size11 = 11.0;
  static const double size12 = 12.0;
  static const double size13 = 13.0;
  static const double size14 = 14.0;
  static const double size15 = 15.0;
  static const double size16 = 16.0;
  static const double size17 = 17.0;
  static const double size18 = 18.0;
  static const double size19 = 19.0;
  static const double size20 = 20.0;
  static const double size22 = 22.0;
  static const double size24 = 24.0;
  static const double size26 = 26.0;
  static const double size28 = 28.0;
  static const double size30 = 30.0;
  static const double size32 = 32.0;
  static const double size34 = 34.0;
  static const double size36 = 36.0;
  static const double size38 = 38.0;
  static const double size40 = 40.0;
  static const double size42 = 42.0;
  static const double size44 = 44.0;
  static const double size48 = 48.0;
  static const double size52 = 52.0;
  static const double size56 = 56.0;
  static const double size60 = 60.0;
  static const double size64 = 64.0;
  static const double size72 = 72.0;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;

  // Predefined Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: size56,
    fontWeight: bold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: size44,
    fontWeight: semiBold,
    letterSpacing: letterSpacingTight,
    height: lineHeightTight,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: size36,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightTight,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: size32,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: size28,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: size24,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: size22,
    fontWeight: semiBold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: size20,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: size18,
    fontWeight: medium,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: size16,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: size14,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: size12,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: size14,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: size12,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: size10,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  // Button Text Styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: size16,
    fontWeight: semiBold,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: size14,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: size12,
    fontWeight: medium,
    letterSpacing: letterSpacingWide,
    height: lineHeightNormal,
  );

  // Caption Styles
  static const TextStyle captionRegular = TextStyle(
    fontSize: size12,
    fontWeight: regular,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: size12,
    fontWeight: bold,
    letterSpacing: letterSpacingNormal,
    height: lineHeightNormal,
  );

  // Overline Styles
  static const TextStyle overlineRegular = TextStyle(
    fontSize: size10,
    fontWeight: regular,
    letterSpacing: letterSpacingWider,
    height: lineHeightNormal,
  );

  static const TextStyle overlineBold = TextStyle(
    fontSize: size10,
    fontWeight: bold,
    letterSpacing: letterSpacingWider,
    height: lineHeightNormal,
  );

  // Helper methods for dynamic styles
  static TextStyle getHeadingStyle(double size, {FontWeight? weight}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight ?? semiBold,
      letterSpacing: letterSpacingNormal,
      height: lineHeightTight,
    );
  }

  static TextStyle getBodyStyle(double size, {FontWeight? weight}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight ?? regular,
      letterSpacing: letterSpacingNormal,
      height: lineHeightNormal,
    );
  }

  static TextStyle getLabelStyle(double size, {FontWeight? weight}) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight ?? medium,
      letterSpacing: letterSpacingWide,
      height: lineHeightNormal,
    );
  }
}