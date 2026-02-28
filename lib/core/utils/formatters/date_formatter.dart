// lib/core/utils/formatters/date_formatter.dart

import 'package:intl/intl.dart';
import 'package:menahariya/core/constants/app_constants.dart';
import 'package:menahariya/core/utils/helpers/date_helper.dart';

class DateFormatter {
  // Private constructor
  DateFormatter._();

  // Standard date formats
  static const String fullDate = 'EEEE, MMMM d, yyyy';
  static const String longDate = 'MMMM d, yyyy';
  static const String mediumDate = 'MMM d, yyyy';
  static const String shortDate = 'MM/dd/yyyy';
  static const String isoDate = 'yyyy-MM-dd';

  static const String fullTime = 'h:mm:ss a';
  static const String shortTime = 'h:mm a';
  static const String militaryTime = 'HH:mm';

  static const String fullDateTime = 'EEEE, MMMM d, yyyy \'at\' h:mm a';
  static const String longDateTime = 'MMM d, yyyy h:mm a';
  static const String shortDateTime = 'MM/dd/yyyy h:mm a';
  static const String isoDateTime = 'yyyy-MM-dd HH:mm:ss';

  // Format date with custom pattern
  static String format(DateTime date, {String pattern = mediumDate}) {
    try {
      return DateFormat(pattern).format(date);
    } catch (e) {
      return date.toString();
    }
  }

  // Format for display (e.g., "Monday, January 1, 2024")
  static String toDisplayDate(DateTime date) {
    return format(date, pattern: fullDate);
  }

  // Format for compact display (e.g., "Jan 1, 2024")
  static String toCompactDate(DateTime date) {
    return format(date, pattern: mediumDate);
  }

  // Format for lists (e.g., "01/01/2024")
  static String toListDate(DateTime date) {
    return format(date, pattern: shortDate);
  }

  // Format for API (e.g., "2024-01-01")
  static String toApiDate(DateTime date) {
    return format(date, pattern: isoDate);
  }

  // Format time (e.g., "3:30 PM")
  static String toTime(DateTime date, {bool use24Hours = false}) {
    if (use24Hours) {
      return format(date, pattern: militaryTime);
    }
    return format(date, pattern: shortTime);
  }

  // Format for datetime picker (e.g., "2024-01-01 15:30")
  static String forPicker(DateTime date) {
    return format(date, pattern: 'yyyy-MM-dd HH:mm');
  }

  // Format relative time (e.g., "2 hours ago", "Tomorrow")
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    const weekAgo = Duration(days: 7);

    final dateWithoutTime = DateTime(date.year, date.month, date.day);

    if (dateWithoutTime == today) {
      return 'Today at ${toTime(date)}';
    } else if (dateWithoutTime == tomorrow) {
      return 'Tomorrow at ${toTime(date)}';
    } else if (dateWithoutTime == yesterday) {
      return 'Yesterday at ${toTime(date)}';
    } else if (date.isAfter(now.subtract(weekAgo))) {
      // Within the last week
      return '${DateFormat('EEEE').format(date)} at ${toTime(date)}';
    } else {
      return toDisplayDate(date);
    }
  }

  // Format for ticket (e.g., "Mon, 01 Jan 2024 • 3:30 PM")
  static String forTicket(DateTime date) {
    final day = DateFormat('E').format(date);
    final dayNum = DateFormat('d').format(date);
    final month = DateFormat('MMM').format(date);
    final year = DateFormat('yyyy').format(date);
    final time = toTime(date);
    return '$day, $dayNum $month $year • $time';
  }

  // Format for seat lock expiry
  static String formatExpiry(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.inSeconds < 0) {
      return 'Expired';
    } else if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s remaining';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
  }

  // Format trip duration
  static String formatTripDuration(DateTime departure, DateTime arrival) {
    final duration = arrival.difference(departure);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  // Get date range string (e.g., "Jan 1 - Jan 7, 2024")
  static String dateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    } else if (start.year == end.year) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    } else {
      return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }

  // Parse date from string with multiple formats
  static DateTime? tryParse(String dateString) {
    final formats = [
      isoDate,
      isoDateTime,
      shortDate,
      mediumDate,
      longDate,
      fullDate,
      'dd/MM/yyyy',
      'dd-MM-yyyy',
      'yyyy/MM/dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (_) {}
    }
    return null;
  }

  // Format for age calculation
  static String formatAge(DateTime birthDate) {
    final age = DateHelper.getAge(birthDate);
    return '$age years';
  }

  // Format for month-year (e.g., "January 2024")
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Format for day-month (e.g., "01 Jan")
  static String dayMonth(DateTime date) {
    return DateFormat('dd MMM').format(date);
  }

  // Get week number
  static String weekNumber(DateTime date) {
    final weekNum = DateHelper.getWeekOfMonth(date);
    return 'Week $weekNum';
  }

  static String getDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
  // Format for calendar header
  static String calendarHeader(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  // Format for calendar day
  static String calendarDay(DateTime date) {
    return DateFormat('d').format(date);
  }

  // Check if date is valid
  static bool isValidDate(String dateString) {
    return tryParse(dateString) != null;
  }

  // Get next occurrence of weekday
  static DateTime nextWeekday(DateTime from, int weekday) {
    var date = from;
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  // Get previous occurrence of weekday
  static DateTime previousWeekday(DateTime from, int weekday) {
    var date = from;
    while (date.weekday != weekday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  // Format for notification timestamp
  static String forNotification(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return toCompactDate(date);
    }
  }
}