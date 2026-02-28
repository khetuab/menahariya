// lib/core/utils/extensions/datetime_extension.dart

import 'package:intl/intl.dart';
import 'package:menahariya/core/utils/helpers/date_helper.dart';
import 'package:menahariya/core/utils/formatters/date_formatter.dart';

extension DateTimeExtension on DateTime {
  // Format with custom pattern
  String format([String pattern = DateFormatter.mediumDate]) =>
      DateFormatter.format(this, pattern: pattern);

  // Get relative time
  String get timeAgo => DateHelper.getRelativeTime(this);

  // Get relative future time
  String get timeFromNow => DateHelper.getRelativeFutureTime(this);

  // Check if today
  bool get isToday => DateHelper.isToday(this);

  // Check if tomorrow
  bool get isTomorrow => DateHelper.isTomorrow(this);

  // Check if yesterday
  bool get isYesterday => DateHelper.isYesterday(this);

  // Get day name
  String get dayName => DateHelper.getDayName(this);

  // Get short day name
  String get shortDayName => DateHelper.getShortDayName(this);

  // Get month name
  String get monthName => DateHelper.getMonthName(this);

  // Get short month name
  String get shortMonthName => DateHelper.getShortMonthName(this);

  // Check if weekend
  bool get isWeekend => DateHelper.isWeekend(this);

  // Get week of month
  int get weekOfMonth => DateHelper.getWeekOfMonth(this);

  // Get start of day
  DateTime get startOfDay => DateHelper.startOfDay(this);

  // Get end of day
  DateTime get endOfDay => DateHelper.endOfDay(this);

  // Get start of week
  DateTime get startOfWeek => DateHelper.startOfWeek(this);

  // Get end of week
  DateTime get endOfWeek => DateHelper.endOfWeek(this);

  // Get start of month
  DateTime get startOfMonth => DateHelper.startOfMonth(this);

  // Get end of month
  DateTime get endOfMonth => DateHelper.endOfMonth(this);

  // Check if between two dates
  bool isBetween(DateTime start, DateTime end) =>
      DateHelper.isWithinRange(this, start, end);

  // Add business days
  DateTime addBusinessDays(int days) {
    var result = this;
    var added = 0;
    while (added < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        added++;
      }
    }
    return result;
  }

  // Get difference in business days
  int businessDaysUntil(DateTime other) {
    if (isAfter(other)) return 0;

    var count = 0;
    var current = this;
    while (current.isBefore(other)) {
      if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  // Get age from this date
  int get age => DateHelper.getAge(this);

  // Check if same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Check if same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  // Check if same year as another date
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  // Get first day of month
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  // Get last day of month
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  // Get next month
  DateTime get nextMonth => DateTime(year, month + 1, day);

  // Get previous month
  DateTime get previousMonth => DateTime(year, month - 1, day);

  // Get next year
  DateTime get nextYear => DateTime(year + 1, month, day);

  // Get previous year
  DateTime get previousYear => DateTime(year - 1, month, day);

  // Add months safely
  DateTime addMonths(int months) {
    final newMonth = month + months;
    final newYear = year + (newMonth - 1) ~/ 12;
    final normalizedMonth = ((newMonth - 1) % 12) + 1;

    // Handle invalid dates (e.g., Jan 31 + 1 month)
    final lastDayOfMonth = DateTime(newYear, normalizedMonth + 1, 0).day;
    final newDay = day > lastDayOfMonth ? lastDayOfMonth : day;

    return DateTime(newYear, normalizedMonth, newDay, hour, minute, second, millisecond, microsecond);
  }

  // Subtract months safely
  DateTime subtractMonths(int months) => addMonths(-months);

  // Get quarter
  int get quarter => ((month - 1) ~/ 3) + 1;

  // Get week number of year
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    return ((difference(startOfDay).inDays + daysOffset) / 7).ceil();
  }

  // Check if date is within current week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.startOfWeek;
    final weekEnd = now.endOfWeek;
    return isBetween(weekStart, weekEnd);
  }

  // Check if date is within current month
  bool get isThisMonth => isSameMonth(DateTime.now());

  // Check if date is within current year
  bool get isThisYear => isSameYear(DateTime.now());

  // Format for ticket
  String get forTicket => DateFormatter.forTicket(this);

  // Format for notification
  String get forNotification => DateFormatter.forNotification(this);

  // Format for age
  String get forAge => DateFormatter.formatAge(this);

  // Get time until this date
  Duration get timeUntil => difference(DateTime.now());

  // Get time since this date
  Duration get timeSince => DateTime.now().difference(this);

  // Check if date is in past
  bool get isPast => isBefore(DateTime.now());

  // Check if date is in future
  bool get isFuture => isAfter(DateTime.now());

  // Get the nearest occurrence of a weekday
  DateTime nearestWeekday(int targetWeekday) {
    var date = this;
    while (date.weekday != targetWeekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  // Get all dates until another date
  List<DateTime> datesUntil(DateTime end, {bool inclusive = true}) {
    final dates = <DateTime>[];
    var current = this;
    final condition = inclusive ? current.isBefore(end) || current.isSameDay(end) : current.isBefore(end);

    while (condition) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  // Format as ISO string
  String get toIsoString => toIso8601String();

  // Get UNIX timestamp
  int get toUnixTimestamp => millisecondsSinceEpoch ~/ 1000;

  // Create from UNIX timestamp
  static DateTime fromUnixTimestamp(int timestamp) =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  // Get display string with timezone consideration
  String toLocalizedString({String locale = 'en'}) {
    final formatter = DateFormat.yMMMMd(locale);
    return formatter.format(this);
  }

  // Get short display string
  String toShortString() => DateFormatter.toCompactDate(this);

  // Get medium display string
  String toMediumString() => DateFormatter.toDisplayDate(this);

  // Get long display string with time
  String toLongString() => DateFormatter.fullDateTime;
}