// lib/core/theme/light_theme.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_colors.dart';
import 'package:menahariya/core/constants/app_fonts.dart';
import 'package:menahariya/core/constants/app_dimens.dart';

class AppTheme {
  // Private constructor
  AppTheme._();

  // Light Theme
  static final ThemeData light = ThemeData(
    // Brightness
    brightness: Brightness.light,

    // Primary Colors
    primaryColor: AppColors.primaryGreen,
    primaryColorLight: AppColors.primaryGreenLight,
    primaryColorDark: AppColors.primaryGreenDark,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryYellow,
      tertiary: AppColors.primaryRed,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      onSurface: AppColors.textPrimaryLight,
      onBackground: AppColors.textPrimaryLight,
      onError: AppColors.white,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: AppDimens.elevation2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppDimens.fontSize18,
        fontWeight: AppFonts.semiBold,
        color: AppColors.textPrimaryLight,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.textPrimaryLight,
        size: AppDimens.iconSize24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.textPrimaryLight,
        size: AppDimens.iconSize24,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppFonts.displayLarge,
      displayMedium: AppFonts.displayMedium,
      displaySmall: AppFonts.displaySmall,
      headlineLarge: AppFonts.headlineLarge,
      headlineMedium: AppFonts.headlineMedium,
      headlineSmall: AppFonts.headlineSmall,
      titleLarge: AppFonts.titleLarge,
      titleMedium: AppFonts.titleMedium,
      titleSmall: AppFonts.titleSmall,
      bodyLarge: AppFonts.bodyLarge,
      bodyMedium: AppFonts.bodyMedium,
      bodySmall: AppFonts.bodySmall,
      labelLarge: AppFonts.labelLarge,
      labelMedium: AppFonts.labelMedium,
      labelSmall: AppFonts.labelSmall,
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
      fontFamily: AppFonts.fontFamilyPrimary,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding24,
          vertical: AppDimens.padding12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize16,
          fontWeight: AppFonts.semiBold,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
        elevation: AppDimens.elevation2,
        shadowColor: AppColors.primaryGreen.withOpacity(AppDimens.opacityLow),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding24,
          vertical: AppDimens.padding12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize16,
          fontWeight: AppFonts.medium,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding16,
          vertical: AppDimens.padding8,
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize14,
          fontWeight: AppFonts.medium,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.all(AppDimens.padding16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.grey300, width: 1),
      ),
      hintStyle: const TextStyle(
        color: AppColors.textHintLight,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryLight,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      errorStyle: const TextStyle(
        color: AppColors.error,
        fontSize: AppDimens.fontSize12,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      prefixIconColor: AppColors.textHintLight,
      suffixIconColor: AppColors.textHintLight,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: AppDimens.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      margin: const EdgeInsets.all(AppDimens.margin8),
      clipBehavior: Clip.antiAlias,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.white,
      elevation: AppDimens.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: AppDimens.fontSize18,
        fontWeight: AppFonts.semiBold,
        color: AppColors.textPrimaryLight,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppDimens.fontSize14,
        color: AppColors.textSecondaryLight,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.white,
      elevation: AppDimens.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius20),
        ),
      ),
      modalBackgroundColor: AppColors.white,
      modalElevation: AppDimens.elevation8,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey400;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey400;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen.withOpacity(0.5);
        }
        return AppColors.grey300;
      }),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGreen,
      circularTrackColor: AppColors.grey200,
      linearTrackColor: AppColors.grey200,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: AppDimens.dividerNormal,
      space: AppDimens.padding24,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      elevation: AppDimens.elevation4,
      shape: CircleBorder(),
    ),

    // Navigation Bar Theme (Bottom Navigation)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primaryGreen.withOpacity(0.1),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: AppDimens.fontSize12,
            fontWeight: AppFonts.medium,
            fontFamily: AppFonts.fontFamilyPrimary,
          );
        }
        return const TextStyle(
          color: AppColors.textHintLight,
          fontSize: AppDimens.fontSize12,
          fontWeight: AppFonts.regular,
          fontFamily: AppFonts.fontFamilyPrimary,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.primaryGreen, size: AppDimens.iconSize24);
        }
        return const IconThemeData(color: AppColors.textHintLight, size: AppDimens.iconSize24);
      }),
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryGreen,
      unselectedLabelColor: AppColors.textHintLight,
      labelStyle: TextStyle(
        fontSize: AppDimens.fontSize14,
        fontWeight: AppFonts.medium,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppDimens.fontSize14,
        fontWeight: AppFonts.regular,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      indicatorColor: AppColors.primaryGreen,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // Snackbar Theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.grey800,
      contentTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      actionTextColor: AppColors.primaryYellow,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radius8)),
      ),
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
      textStyle: const TextStyle(
        color: AppColors.white,
        fontSize: AppDimens.fontSize12,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Popup Menu Theme
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.white,
      elevation: AppDimens.elevation4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radius8)),
      ),
      textStyle: TextStyle(
        color: AppColors.textPrimaryLight,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Scaffold Background Color
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // Canvas Color
    canvasColor: AppColors.backgroundLight,

    // Card Color
    cardColor: AppColors.white,

    // Shadow Color
    shadowColor: AppColors.grey600.withOpacity(0.1),

    // Highlight Color
    highlightColor: AppColors.primaryGreen.withOpacity(0.1),

    // Splash Color
    splashColor: AppColors.primaryGreen.withOpacity(0.1),

    // Hover Color
    hoverColor: AppColors.primaryGreen.withOpacity(0.05),

    // Focus Color
    focusColor: AppColors.primaryGreen.withOpacity(0.1),

    // Disabled Color
    disabledColor: AppColors.grey400,

    // Hint Color
    hintColor: AppColors.textHintLight,

    // Divider Color
    dividerColor: AppColors.dividerLight,

    // Primary Swatch (for backwards compatibility)
    primarySwatch: const MaterialColor(0xFF1A5F3E, {
      50: Color(0xFFE8F0EC),
      100: Color(0xFFC5D9D1),
      200: Color(0xFF9EBFB3),
      300: Color(0xFF77A595),
      400: Color(0xFF5A927E),
      500: Color(0xFF1A5F3E), // primary
      600: Color(0xFF175738),
      700: Color(0xFF134D30),
      800: Color(0xFF0F4328),
      900: Color(0xFF08321B),
    }),

    // Visual Density
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Material Tap Target Size
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // Apply Elevation Overlay
    applyElevationOverlayColor: false,

    // Use Material 3
    useMaterial3: true,
  );
  static final ThemeData dark = ThemeData(
    // Brightness
    brightness: Brightness.dark,

    // Primary Colors
    primaryColor: AppColors.primaryGreen,
    primaryColorLight: AppColors.primaryGreenLight,
    primaryColorDark: AppColors.primaryGreenDark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryYellow,
      tertiary: AppColors.primaryRed,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.errorLight,
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      onError: AppColors.white,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: AppDimens.elevation2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppDimens.fontSize18,
        fontWeight: AppFonts.semiBold,
        color: AppColors.textPrimaryDark,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppDimens.iconSize24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: AppDimens.iconSize24,
      ),
    ),

    // Text Theme
    textTheme: const TextTheme(
      displayLarge: AppFonts.displayLarge,
      displayMedium: AppFonts.displayMedium,
      displaySmall: AppFonts.displaySmall,
      headlineLarge: AppFonts.headlineLarge,
      headlineMedium: AppFonts.headlineMedium,
      headlineSmall: AppFonts.headlineSmall,
      titleLarge: AppFonts.titleLarge,
      titleMedium: AppFonts.titleMedium,
      titleSmall: AppFonts.titleSmall,
      bodyLarge: AppFonts.bodyLarge,
      bodyMedium: AppFonts.bodyMedium,
      bodySmall: AppFonts.bodySmall,
      labelLarge: AppFonts.labelLarge,
      labelMedium: AppFonts.labelMedium,
      labelSmall: AppFonts.labelSmall,
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
      fontFamily: AppFonts.fontFamilyPrimary,
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding24,
          vertical: AppDimens.padding12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize16,
          fontWeight: AppFonts.semiBold,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
        elevation: AppDimens.elevation2,
        shadowColor: AppColors.primaryGreen.withOpacity(AppDimens.opacityLow),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        minimumSize: const Size(double.infinity, AppDimens.buttonHeightLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding24,
          vertical: AppDimens.padding12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize16,
          fontWeight: AppFonts.medium,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreenLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding16,
          vertical: AppDimens.padding8,
        ),
        textStyle: const TextStyle(
          fontSize: AppDimens.fontSize14,
          fontWeight: AppFonts.medium,
          fontFamily: AppFonts.fontFamilyPrimary,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey800,
      contentPadding: const EdgeInsets.all(AppDimens.padding16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        borderSide: const BorderSide(color: AppColors.grey600, width: 1),
      ),
      hintStyle: const TextStyle(
        color: AppColors.textHintDark,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryDark,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      errorStyle: const TextStyle(
        color: AppColors.errorLight,
        fontSize: AppDimens.fontSize12,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      prefixIconColor: AppColors.textHintDark,
      suffixIconColor: AppColors.textHintDark,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: AppDimens.elevation2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
      ),
      margin: const EdgeInsets.all(AppDimens.margin8),
      clipBehavior: Clip.antiAlias,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppDimens.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      titleTextStyle: const TextStyle(
        fontSize: AppDimens.fontSize18,
        fontWeight: AppFonts.semiBold,
        color: AppColors.textPrimaryDark,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontSize: AppDimens.fontSize14,
        color: AppColors.textSecondaryDark,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: AppDimens.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radius20),
        ),
      ),
      modalBackgroundColor: AppColors.surfaceDark,
      modalElevation: AppDimens.elevation8,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey600;
      }),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey600;
      }),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen;
        }
        return AppColors.grey500;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryGreen.withOpacity(0.5);
        }
        return AppColors.grey700;
      }),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryGreen,
      circularTrackColor: AppColors.grey700,
      linearTrackColor: AppColors.grey700,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: AppDimens.dividerNormal,
      space: AppDimens.padding24,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      elevation: AppDimens.elevation4,
      shape: CircleBorder(),
    ),

    // Navigation Bar Theme (Bottom Navigation)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      indicatorColor: AppColors.primaryGreen.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
        if (states.contains(MaterialState.selected)) {
          return const TextStyle(
            color: AppColors.primaryGreenLight,
            fontSize: AppDimens.fontSize12,
            fontWeight: AppFonts.medium,
            fontFamily: AppFonts.fontFamilyPrimary,
          );
        }
        return const TextStyle(
          color: AppColors.textHintDark,
          fontSize: AppDimens.fontSize12,
          fontWeight: AppFonts.regular,
          fontFamily: AppFonts.fontFamilyPrimary,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(color: AppColors.primaryGreenLight, size: AppDimens.iconSize24);
        }
        return const IconThemeData(color: AppColors.textHintDark, size: AppDimens.iconSize24);
      }),
    ),

    // Tab Bar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.primaryGreenLight,
      unselectedLabelColor: AppColors.textHintDark,
      labelStyle: TextStyle(
        fontSize: AppDimens.fontSize14,
        fontWeight: AppFonts.medium,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: AppDimens.fontSize14,
        fontWeight: AppFonts.regular,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      indicatorColor: AppColors.primaryGreenLight,
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // Snackbar Theme
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.grey800,
      contentTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
      actionTextColor: AppColors.primaryYellow,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radius8)),
      ),
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(AppDimens.radius4),
      ),
      textStyle: const TextStyle(
        color: AppColors.white,
        fontSize: AppDimens.fontSize12,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Popup Menu Theme
    popupMenuTheme: const PopupMenuThemeData(
      color: AppColors.surfaceDark,
      elevation: AppDimens.elevation4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppDimens.radius8)),
      ),
      textStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: AppDimens.fontSize14,
        fontFamily: AppFonts.fontFamilyPrimary,
      ),
    ),

    // Scaffold Background Color
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // Canvas Color
    canvasColor: AppColors.backgroundDark,

    // Card Color
    cardColor: AppColors.surfaceDark,

    // Shadow Color
    shadowColor: AppColors.black.withOpacity(0.3),

    // Highlight Color
    highlightColor: AppColors.primaryGreen.withOpacity(0.2),

    // Splash Color
    splashColor: AppColors.primaryGreen.withOpacity(0.2),

    // Hover Color
    hoverColor: AppColors.primaryGreen.withOpacity(0.1),

    // Focus Color
    focusColor: AppColors.primaryGreen.withOpacity(0.2),

    // Disabled Color
    disabledColor: AppColors.grey600,

    // Hint Color
    hintColor: AppColors.textHintDark,

    // Divider Color
    dividerColor: AppColors.dividerDark,

    // Primary Swatch (for backwards compatibility)
    primarySwatch: const MaterialColor(0xFF1A5F3E, {
      50: Color(0xFFE8F0EC),
      100: Color(0xFFC5D9D1),
      200: Color(0xFF9EBFB3),
      300: Color(0xFF77A595),
      400: Color(0xFF5A927E),
      500: Color(0xFF1A5F3E),
      600: Color(0xFF175738),
      700: Color(0xFF134D30),
      800: Color(0xFF0F4328),
      900: Color(0xFF08321B),
    }),

    // Visual Density
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // Material Tap Target Size
    materialTapTargetSize: MaterialTapTargetSize.padded,

    // Apply Elevation Overlay
    applyElevationOverlayColor: true,

    // Use Material 3
    useMaterial3: true,
  );
}