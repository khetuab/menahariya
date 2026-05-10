// // lib/core/constants/app_colors.dart
//
// import 'package:flutter/material.dart';
//
// class AppColors {
//   // Private constructor to prevent instantiation
//   AppColors._();
//
//   // Primary Colors - Ethiopian Theme (Green, Yellow, Red)
//   static const Color primaryGreen = Color(0xFF1A5F3E); // Deep Ethiopian Green
//   static const Color primaryYellow = Color(0xFFFCD116); // Ethiopian Yellow
//   static const Color primaryRed = Color(0xFFDA121A); // Ethiopian Red
//   static const Color primaryOrange = Color(0xFFF6C111); // Ethiopian Red
//
//   // Primary Variants
//   static const Color primaryGreenLight = Color(0xFF2E7D5E);
//   static const Color primaryGreenDark = Color(0xFF0D4A2F);
//   static const Color primaryYellowLight = Color(0xFFFFE04B);
//   static const Color primaryYellowDark = Color(0xFFE5B800);
//   static const Color primaryRedLight = Color(0xFFE63E3E);
//   static const Color primaryRedDark = Color(0xFFB80D0D);
//
//   // Secondary Colors
//   static const Color secondaryBlue = Color(0xFF1976D2);
//   static const Color secondaryBlueLight = Color(0xFF42A5F5);
//   static const Color secondaryBlueDark = Color(0xFF0D47A1);
//
//   static const Color secondaryOrange = Color(0xFFFF9800);
//   static const Color secondaryOrangeLight = Color(0xFFFFB74D);
//   static const Color secondaryOrangeDark = Color(0xFFF57C00);
//
//   static const Color secondaryPurple = Color(0xFF7B1FA2);
//   static const Color secondaryPurpleLight = Color(0xFF9C27B0);
//   static const Color secondaryPurpleDark = Color(0xFF4A0072);
//
//   // Neutral Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color transparent = Color(0x00000000);
//
//   // Grey Scale
//   static const Color grey50 = Color(0xFFFAFAFA);
//   static const Color grey100 = Color(0xFFF5F5F5);
//   static const Color grey200 = Color(0xFFEEEEEE);
//   static const Color grey300 = Color(0xFFE0E0E0);
//   static const Color grey400 = Color(0xFFBDBDBD);
//   static const Color grey500 = Color(0xFF9E9E9E);
//   static const Color grey600 = Color(0xFF757575);
//   static const Color grey700 = Color(0xFF616161);
//   static const Color grey800 = Color(0xFF424242);
//   static const Color grey900 = Color(0xFF212121);
//
//   // Semantic Colors
//   static const Color success = Color(0xFF2E7D32);
//   static const Color successLight = Color(0xFF4CAF50);
//   static const Color successDark = Color(0xFF1B5E20);
//
//   static const Color error = Color(0xFFC62828);
//   static const Color errorLight = Color(0xFFEF5350);
//   static const Color errorDark = Color(0xFF8B0000);
//
//   static const Color warning = Color(0xFFFF8F00);
//   static const Color warningLight = Color(0xFFFFB300);
//   static const Color warningDark = Color(0xFFFF6F00);
//
//   static const Color info = Color(0xFF0277BD);
//   static const Color infoLight = Color(0xFF29B6F6);
//   static const Color infoDark = Color(0xFF01579B);
//
//   // Background Colors
//   static const Color backgroundLight = Color(0xFFF8F9FA);
//   static const Color backgroundDark = Color(0xFF121212);
//   static const Color surfaceLight = white;
//   static const Color surfaceDark = Color(0xFF1E1E1E);
//
//   // Text Colors
//   static const Color textPrimaryLight = Color(0xFF2C3E50);
//   static const Color textSecondaryLight = Color(0xFF7F8C8D);
//   static const Color textHintLight = Color(0xFFBDC3C7);
//   static const Color textDisabledLight = Color(0xFF95A5A6);
//
//   static const Color textPrimaryDark = Color(0xFFECF0F1);
//   static const Color textSecondaryDark = Color(0xFFBDC3C7);
//   static const Color textHintDark = Color(0xFF7F8C8D);
//   static const Color textDisabledDark = Color(0xFF95A5A6);
//
//   // Border Colors
//   static const Color borderLight = Color(0xFFE0E0E0);
//   static const Color borderDark = Color(0xFF424242);
//   static const Color dividerLight = Color(0xFFEEEEEE);
//   static const Color dividerDark = Color(0xFF333333);
//
//   // Seat Status Colors
//   static const Color seatAvailable = Color(0xFF2E7D32); // Green
//   static const Color seatSelected = Color(0xFF1976D2); // Blue
//   static const Color seatLocked = Color(0xFFFF9800); // Orange
//   static const Color seatBooked = Color(0xFFC62828); // Red
//   static const Color seatDisabled = Color(0xFF9E9E9E); // Grey
//
//   // Gradient Definitions
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       primaryGreen,
//       primaryYellow,
//       primaryRed,
//     ],
//   );
//
//   static const LinearGradient greenGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       primaryGreenLight,
//       primaryGreen,
//       primaryGreenDark,
//     ],
//   );
//
//   static const LinearGradient sunsetGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [
//       primaryOrange,
//       primaryRed,
//       primaryRedDark,
//     ],
//   );
//
//   // Opacity Values
//   static const double opacityHigh = 0.9;
//   static const double opacityMedium = 0.6;
//   static const double opacityLow = 0.3;
//   static const double opacityDisabled = 0.12;
//
//   // Helper methods
//   static Color withOpacity(Color color, double opacity) {
//     return color.withOpacity(opacity);
//   }
//
//   static Color getSeatColor(String status) {
//     switch (status) {
//       case 'available':
//         return seatAvailable;
//       case 'selected':
//         return seatSelected;
//       case 'locked':
//         return seatLocked;
//       case 'booked':
//       case 'paid':
//       case 'used':
//         return seatBooked;
//       case 'disabled':
//         return seatDisabled;
//       default:
//         return grey500;
//     }
//   }
//
//   static Color getPaymentStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//       case 'success':
//         return success;
//       case 'pending':
//         return warning;
//       case 'failed':
//       case 'cancelled':
//         return error;
//       case 'refunded':
//         return info;
//       default:
//         return grey500;
//     }
//   }
//
//   static Color getTripStatusColor(String status) {
//     switch (status) {
//       case 'scheduled':
//         return info;
//       case 'departed':
//         return primaryGreen;
//       case 'completed':
//         return success;
//       case 'cancelled':
//         return error;
//       case 'delayed':
//         return warning;
//       default:
//         return grey500;
//     }
//   }
// }
// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors - Dark Blue Theme
  static const Color primaryGreen = Color(0xFF0F172A); // Dark Navy Blue
  static const Color primaryYellow = Color(0xFF1E3A8A); // Royal Blue
  static const Color primaryRed = Color(0xFF2563EB); // Bright Blue
  static const Color primaryOrange = Color(0xFF3B82F6); // Sky Blue

  // Primary Variants
  static const Color primaryGreenLight = Color(0xFF1E293B);
  static const Color primaryGreenDark = Color(0xFF020617);

  static const Color primaryYellowLight = Color(0xFF2563EB);
  static const Color primaryYellowDark = Color(0xFF1D4ED8);

  static const Color primaryRedLight = Color(0xFF60A5FA);
  static const Color primaryRedDark = Color(0xFF1E40AF);

  // Secondary Colors
  static const Color secondaryBlue = Color(0xFF0EA5E9);
  static const Color secondaryBlueLight = Color(0xFF38BDF8);
  static const Color secondaryBlueDark = Color(0xFF0369A1);

  static const Color secondaryOrange = Color(0xFF0284C7);
  static const Color secondaryOrangeLight = Color(0xFF38BDF8);
  static const Color secondaryOrangeDark = Color(0xFF075985);

  static const Color secondaryPurple = Color(0xFF312E81);
  static const Color secondaryPurpleLight = Color(0xFF4F46E5);
  static const Color secondaryPurpleDark = Color(0xFF1E1B4B);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Grey Scale
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Semantic Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF166534);

  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFF38BDF8);
  static const Color infoDark = Color(0xFF075985);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundDark = Color(0xFF020617);

  static const Color surfaceLight = white;
  static const Color surfaceDark = Color(0xFF0F172A);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textHintLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textHintDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF1E293B);

  // Seat Status Colors
  static const Color seatAvailable = Color(0xFF2563EB); // Blue
  static const Color seatSelected = Color(0xFF0EA5E9); // Sky Blue
  static const Color seatLocked = Color(0xFFF59E0B); // Amber
  static const Color seatBooked = Color(0xFFDC2626); // Red
  static const Color seatDisabled = Color(0xFF64748B); // Slate

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryGreen,
      primaryYellow,
      primaryRed,
    ],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryGreenLight,
      primaryGreen,
      primaryGreenDark,
    ],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryOrange,
      primaryRed,
      primaryRedDark,
    ],
  );

  // Opacity Values
  static const double opacityHigh = 0.9;
  static const double opacityMedium = 0.6;
  static const double opacityLow = 0.3;
  static const double opacityDisabled = 0.12;

  // Helper methods
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static Color getSeatColor(String status) {
    switch (status) {
      case 'available':
        return seatAvailable;
      case 'selected':
        return seatSelected;
      case 'locked':
        return seatLocked;
      case 'booked':
      case 'paid':
      case 'used':
        return seatBooked;
      case 'disabled':
        return seatDisabled;
      default:
        return grey500;
    }
  }

  static Color getPaymentStatusColor(String status) {
    switch (status) {
      case 'completed':
      case 'success':
        return success;
      case 'pending':
        return warning;
      case 'failed':
      case 'cancelled':
        return error;
      case 'refunded':
        return info;
      default:
        return grey500;
    }
  }

  static Color getTripStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return info;
      case 'departed':
        return primaryGreen;
      case 'completed':
        return success;
      case 'cancelled':
        return error;
      case 'delayed':
        return warning;
      default:
        return grey500;
    }
  }
}