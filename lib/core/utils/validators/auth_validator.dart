// lib/core/utils/validators/auth_validator.dart

import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/constants/app_strings.dart';

class AuthValidator {
  // Private constructor
  AuthValidator._();

  /// Phone number validation (Ethiopian format)
  // Phone number validation (Ethiopian format)
  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return AppStrings.errorRequired;
    }

    // Remove any spaces or special characters
    String cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    print('🔍 Validating phone: "$phone" -> cleaned: "$cleanedPhone"');

    // Ethiopian phone numbers:
    // - 09XXXXXXXX (10 digits starting with 09)
    // - 2519XXXXXXXX (12 digits starting with 2519)
    // - +2519XXXXXXXX (13 digits starting with +2519)
    final RegExp phoneRegex = RegExp(r'^(09|2519|\+2519)\d{8}$');

    if (!phoneRegex.hasMatch(cleanedPhone)) {
      // Try to fix common input issues
      if (cleanedPhone.length == 9 && cleanedPhone.startsWith('9')) {
        // User entered 9XXXXXXXX without leading 0
        cleanedPhone = '0$cleanedPhone';
        if (phoneRegex.hasMatch(cleanedPhone)) {
          return null;
        }
      } else if (cleanedPhone.length == 12 && cleanedPhone.startsWith('251')) {
        // Already in international format without +
        return null;
      } else if (cleanedPhone.length == 13 && cleanedPhone.startsWith('251')) {
        // Already in international format
        return null;
      }

      return 'Please enter a valid Ethiopian phone number (e.g., 0912345678)';
    }

    if (cleanedPhone.length < AppConstants.minPhoneLength ||
        cleanedPhone.length > AppConstants.maxPhoneLength) {
      return 'Phone number must be between ${AppConstants.minPhoneLength} and ${AppConstants.maxPhoneLength} digits';
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return AppStrings.errorRequired;
    }

    if (password.length < AppConstants.minPasswordLength) {
      return 'Password must be at least '
          '${AppConstants.minPasswordLength} characters';
    }

    if (password.length > AppConstants.maxPasswordLength) {
      return 'Password must not exceed '
          '${AppConstants.maxPasswordLength} characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    if (password.contains(RegExp(r'\s'))) {
      return 'Password cannot contain spaces';
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(
      String? password,
      String? confirmPassword,
      ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return AppStrings.errorRequired;
    }

    if (password != confirmPassword) {
      return AppStrings.errorPasswordMismatch;
    }

    return null;
  }

  /// Email validation (optional)
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return null; // Optional field
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Full name validation
  static String? validateFullName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return AppStrings.errorRequired;
    }

    final String trimmedName = name.trim();

    if (trimmedName.length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (trimmedName.length > 50) {
      return 'Name must not exceed 50 characters';
    }

    // Validate entire string (NOT substring)
    final RegExp nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");

    if (!nameRegex.hasMatch(trimmedName)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  /// OTP validation
  static String? validateOTP(String? otp) {
    if (otp == null || otp.isEmpty) {
      return AppStrings.errorRequired;
    }

    if (otp.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(otp)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  /// Login form validation
  static Map<String, String?> validateLogin(
      String phone,
      String password,
      ) {
    return {
      'phone': validatePhone(phone),
      'password': validatePassword(password),
    };
  }

  /// Registration form validation
  static Map<String, String?> validateRegistration({
    required String fullName,
    required String phone,
    required String password,
    required String confirmPassword,
    String? email,
  }) {
    return {
      'fullName': validateFullName(fullName),
      'phone': validatePhone(phone),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(password, confirmPassword),
      'email': validateEmail(email),
    };
  }

  /// Password reset validation
  static Map<String, String?> validatePasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) {
    return {
      'phone': validatePhone(phone),
      'otp': validateOTP(otp),
      'newPassword': validatePassword(newPassword),
      'confirmPassword':
      validateConfirmPassword(newPassword, confirmPassword),
    };
  }

  /// Check if all fields are valid
  static bool isFormValid(Map<String, String?> validationResult) {
    return validationResult.values.every((error) => error == null);
  }
}