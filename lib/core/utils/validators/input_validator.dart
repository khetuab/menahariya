// lib/core/utils/validators/input_validator.dart

import 'package:flutter/material.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/constants/app_strings.dart';

import 'auth_validator.dart';

class InputValidator {
  // Private constructor
  InputValidator._();

  // Generic required field validation
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName is required'
          : AppStrings.errorRequired;
    }
    return null;
  }

  // Minimum length validation
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return fieldName != null
          ? '$fieldName must be at least $minLength characters'
          : 'Must be at least $minLength characters';
    }
    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > maxLength) {
      return fieldName != null
          ? '$fieldName must not exceed $maxLength characters'
          : 'Must not exceed $maxLength characters';
    }
    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return fieldName != null
          ? '$fieldName must be a number'
          : 'Please enter a valid number';
    }
    return null;
  }

  // Decimal validation
  static String? validateDecimal(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^\d*\.?\d+$').hasMatch(value)) {
      return fieldName != null
          ? '$fieldName must be a valid number'
          : 'Please enter a valid number';
    }
    return null;
  }

  // Range validation
  static String? validateRange(
      String? value, {
        required double min,
        required double max,
        String? fieldName,
      }) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) {
      return fieldName != null
          ? '$fieldName must be a valid number'
          : 'Please enter a valid number';
    }

    if (number < min || number > max) {
      return fieldName != null
          ? '$fieldName must be between $min and $max'
          : 'Value must be between $min and $max';
    }
    return null;
  }

  // Weight validation (cargo)
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorRequired;
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }

    if (weight <= 0) {
      return 'Weight must be greater than 0';
    }

    if (weight > 500) {
      return 'Weight cannot exceed 500 kg';
    }

    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorRequired;
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    if (price > 1000000) {
      return 'Price cannot exceed 1,000,000 ETB';
    }

    return null;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a destination';
    }

    if (value.length < 2) {
      return 'Search query must be at least 2 characters';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? date, {DateTime? minDate, DateTime? maxDate}) {
    if (date == null) {
      return 'Please select a date';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (minDate != null && date.isBefore(minDate)) {
      return 'Date cannot be before ${_formatDate(minDate)}';
    }

    if (maxDate != null && date.isAfter(maxDate)) {
      return 'Date cannot be after ${_formatDate(maxDate)}';
    }

    // For travel dates, cannot be in the past
    if (date.isBefore(today)) {
      return 'Travel date cannot be in the past';
    }

    return null;
  }

  // Time validation
  static String? validateTime(TimeOfDay? time) {
    if (time == null) {
      return 'Please select a time';
    }
    return null;
  }

  // Boolean validation (e.g., terms acceptance)
  static String? validateBoolean(bool? value, {String? message}) {
    if (value != true) {
      return message ?? 'You must accept this to continue';
    }
    return null;
  }

  // List validation (e.g., seat selection)
  static String? validateList(List? list, {String? fieldName}) {
    if (list == null || list.isEmpty) {
      return fieldName != null
          ? 'Please select at least one $fieldName'
          : 'Please make a selection';
    }
    return null;
  }

  // Cargo type validation
  static String? validateCargoType(String? type) {
    if (type == null || type.isEmpty) {
      return 'Please select cargo type';
    }
    return null;
  }

  // Destination validation
  static String? validateDestination(String? destination) {
    if (destination == null || destination.isEmpty) {
      return 'Please select destination';
    }

    if (destination.length < 3) {
      return 'Please enter a valid destination';
    }

    return null;
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Comprehensive validation result
  static Map<String, String?> validateAll(Map<String, dynamic> fields) {
    final Map<String, String?> errors = {};

    fields.forEach((key, value) {
      if (value is String) {
        if (key.contains('phone')) {
          errors[key] = AuthValidator.validatePhone(value);
        } else if (key.contains('email')) {
          errors[key] = AuthValidator.validateEmail(value);
        } else if (key.contains('password')) {
          errors[key] = AuthValidator.validatePassword(value);
        } else if (key.contains('name')) {
          errors[key] = validateFullName(value);
        } else if (key.contains('weight')) {
          errors[key] = validateWeight(value);
        } else if (key.contains('price') || key.contains('amount')) {
          errors[key] = validatePrice(value);
        } else {
          errors[key] = validateRequired(value);
        }
      } else if (value is DateTime) {
        errors[key] = validateDate(value);
      } else if (value is TimeOfDay) {
        errors[key] = validateTime(value);
      } else if (value is bool) {
        errors[key] = validateBoolean(value);
      } else if (value is List) {
        errors[key] = validateList(value);
      }
    });

    return errors;
  }

  static String? validateFullName(String? name) {
    return AuthValidator.validateFullName(name);
  }
}