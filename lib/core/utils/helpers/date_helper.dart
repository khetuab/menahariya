// lib/core/utils/helpers/date_helper.dart

import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_constants.dart';

class DateHelper {
  // Private constructor
  DateHelper._();

  // Format date for display
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormatDisplay);
    return formatter.format(date);
  }

  // Format time for display
  static String formatTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.timeFormatDisplay);
    return formatter.format(date);
  }

  // Format date and time for display
  static String formatDateTime(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateTimeFormatDisplay);
    return formatter.format(date);
  }

  // Format date for API
  static String formatDateForApi(DateTime date) {
    final formatter = DateFormat(AppConstants.dateFormatApi);
    return formatter.format(date);
  }

  // Format time for API (24h)
  static String formatTimeForApi(DateTime date) {
    final formatter = DateFormat(AppConstants.timeFormat24h);
    return formatter.format(date);
  }

  // Format datetime for API
  static String formatDateTimeForApi(DateTime date) {
    final formatter = DateFormat(AppConstants.dateTimeFormatApi);
    return formatter.format(date);
  }

  // Parse date from string
  static DateTime? parseDate(String dateString, {String? format}) {
    try {
      final formatter = DateFormat(format ?? AppConstants.dateFormatApi);
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get relative time (e.g., "2 hours ago", "Tomorrow")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get relative future time (e.g., "in 2 hours")
  static String getRelativeFutureTime(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'in $years year${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'in $months month${months > 1 ? 's' : ''}';
    } else if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Now';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Get day name (e.g., "Monday")
  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  // Get month name (e.g., "January")
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  // Get short day name (e.g., "Mon")
  static String getShortDayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  // Get short month name (e.g., "Jan")
  static String getShortMonthName(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  // Get time range string
  static String getTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  // Get duration string
  static String getDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }

  // Calculate duration between two dates
  static Duration getDurationBetween(DateTime start, DateTime end) {
    return end.difference(start);
  }

  // Get readable duration
  static String getReadableDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return 'Less than a minute';
    }
  }

  // Get week number of month
  static int getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysOffset = firstDayOfMonth.weekday - 1;
    return ((date.day + daysOffset) / 7).ceil();
  }

  // Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(DateTime(date.year, date.month, date.day + daysToAdd));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Get list of dates between range
  static List<DateTime> getDatesBetween(DateTime start, DateTime end) {
    final List<DateTime> dates = [];
    var current = startOfDay(start);
    final last = startOfDay(end);

    while (current.isBefore(last) || current.isAtSameMomentAs(last)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  // Check if date is within range
  static bool isWithinRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end) ||
        date.isAtSameMomentAs(start) ||
        date.isAtSameMomentAs(end);
  }

  // Get age from birthdate
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Get greeting based on time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  // Format for seat lock expiry
  static String formatExpiryTime(DateTime expiryTime) {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds';
    } else {
      return '${difference.inMinutes} minutes';
    }
  }

  // Check if seat lock is about to expire (less than 1 minute)
  static bool isAboutToExpire(DateTime expiryTime) {
    final now = DateTime.now();
    final difference = expiryTime.difference(now);
    return difference.inSeconds < 60;
  }
}