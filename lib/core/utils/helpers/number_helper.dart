// lib/core/utils/helpers/number_helper.dart

import 'package:intl/intl.dart';

class NumberHelper {
  // Private constructor
  NumberHelper._();

  // Format number with commas (e.g., 1,000,000)
  static String formatWithCommas(dynamic number) {
    if (number == null) return '0';

    final formatter = NumberFormat('#,###');
    try {
      if (number is int) {
        return formatter.format(number);
      } else if (number is double) {
        return formatter.format(number);
      } else if (number is String) {
        final parsed = double.tryParse(number);
        return parsed != null ? formatter.format(parsed) : number;
      }
    } catch (e) {
      return number.toString();
    }
    return number.toString();
  }

  // Format number with decimal places
  static String formatWithDecimals(dynamic number, {int decimals = 2}) {
    if (number == null) return '0';

    final formatter = NumberFormat('###,###.##');
    try {
      if (number is int) {
        return formatter.format(number.toDouble());
      } else if (number is double) {
        return number.toStringAsFixed(decimals);
      } else if (number is String) {
        final parsed = double.tryParse(number);
        return parsed != null ? parsed.toStringAsFixed(decimals) : number;
      }
    } catch (e) {
      return number.toString();
    }
    return number.toString();
  }

  // Format as percentage
  static String formatAsPercentage(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  // Format as currency (ETB)
  static String formatAsCurrency(dynamic amount, {bool showSymbol = true}) {
    if (amount == null) return showSymbol ? 'ETB 0' : '0';

    try {
      double value;
      if (amount is int) {
        value = amount.toDouble();
      } else if (amount is double) {
        value = amount;
      } else if (amount is String) {
        value = double.tryParse(amount) ?? 0;
      } else {
        return amount.toString();
      }

      final formatted = formatWithCommas(value.toStringAsFixed(2));
      return showSymbol ? 'ETB $formatted' : formatted;
    } catch (e) {
      return amount.toString();
    }
  }

  // Parse number safely
  static double? parseNumber(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove commas and spaces
    final cleaned = value.replaceAll(RegExp(r'[,\s]'), '');
    return double.tryParse(cleaned);
  }

  // Format as ordinal (e.g., 1st, 2nd, 3rd, 4th)
  static String formatAsOrdinal(int number) {
    if (number < 0) return number.toString();

    final int lastTwoDigits = number % 100;
    final int lastDigit = number % 10;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 13) {
      return '${number}th';
    }

    switch (lastDigit) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Format as distance (km)
  static String formatDistance(double kilometers, {int decimals = 1}) {
    if (kilometers < 1) {
      return '${(kilometers * 1000).toStringAsFixed(0)} m';
    }
    return '${kilometers.toStringAsFixed(decimals)} km';
  }

  // Format as weight (kg)
  static String formatWeight(double kilograms, {int decimals = 1}) {
    if (kilograms < 1) {
      return '${(kilograms * 1000).toStringAsFixed(0)} g';
    }
    return '${kilograms.toStringAsFixed(decimals)} kg';
  }

  // Format as duration in minutes
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    } else {
      return '$hours hr ${remainingMinutes} min';
    }
  }

  // Convert number to words (for check writing, etc.)
  static String numberToWords(int number) {
    if (number == 0) return 'zero';

    final List<String> units = [
      '', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen'
    ];

    final List<String> tens = [
      '', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'
    ];

    if (number < 20) {
      return units[number];
    }

    if (number < 100) {
      return '${tens[number ~/ 10]} ${number % 10 != 0 ? units[number % 10] : ''}'.trim();
    }

    if (number < 1000) {
      return '${units[number ~/ 100]} hundred ${number % 100 != 0 ? numberToWords(number % 100) : ''}'.trim();
    }

    if (number < 1000000) {
      return '${numberToWords(number ~/ 1000)} thousand ${number % 1000 != 0 ? numberToWords(number % 1000) : ''}'.trim();
    }

    return number.toString();
  }

  // Calculate percentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // Round to nearest
  static double roundToNearest(double value, double nearest) {
    return (value / nearest).round() * nearest;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Format as phone number (Ethiopian format)
  static String formatPhoneNumber(String phone) {
    // Remove non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10 && digits.startsWith('09')) {
      // Format: 0912 345 678
      return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
    } else if (digits.length == 12 && digits.startsWith('251')) {
      // Format: +251 91 234 5678
      return '+${digits.substring(0, 3)} ${digits.substring(3, 5)} ${digits.substring(5, 8)} ${digits.substring(8)}';
    }

    return phone;
  }

  // Generate random number within range
  static int randomInRange(int min, int max) {
    return min + (DateTime.now().millisecondsSinceEpoch % (max - min + 1));
  }

  // Check if number is within range
  static bool isInRange(num value, num min, num max) {
    return value >= min && value <= max;
  }

  // Clamp number between min and max
  static num clamp(num value, num min, num max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // Get plural form based on count
  static String pluralize(int count, String singular, {String? plural}) {
    if (count == 1) {
      return '$count $singular';
    }
    return '$count ${plural ?? '${singular}s'}';
  }
}