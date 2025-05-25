import '../models/day.dart';

/// Utilities for working with dates
class CalendarDateUtils {
  /// Gets the first day of the month for a given date
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Gets the last day of the month for a given date
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Gets the day of week (0-6, where 0 is Sunday)
  static int getDayOfWeek(DateTime date) {
    return date.weekday % 7;
  }

  /// Checks if a date is the same day as another date
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if a date is before a given date (ignoring time)
  static bool isBeforeDay(DateTime a, DateTime b) {
    if (a.year < b.year) return true;
    if (a.year > b.year) return false;
    if (a.month < b.month) return true;
    if (a.month > b.month) return false;
    return a.day < b.day;
  }

  /// Checks if a date is after a given date (ignoring time)
  static bool isAfterDay(DateTime a, DateTime b) {
    if (a.year > b.year) return true;
    if (a.year < b.year) return false;
    if (a.month > b.month) return true;
    if (a.month < b.month) return false;
    return a.day > b.day;
  }

  /// Checks if a date is between two other dates (inclusive)
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return !(isBeforeDay(date, start) || isAfterDay(date, end));
  }

  /// Checks if a date has a day of week that should be disabled
  static bool hasDisabledDayOfWeek(DateTime date, List<Day>? disabledDays) {
    if (disabledDays == null || disabledDays.isEmpty) return false;

    // Both date.weekday and our Day.weekdayNumber use the same convention:
    // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
    // Check if the date's weekday matches any of the disabled days
    return disabledDays.any((day) => date.weekday == day.weekdayNumber);
  }

  /// Formats a date as a month year string (e.g. "August 2025")
  static String formatMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Formats a date as a day month string (e.g. "Mon, Aug 17")
  static String formatDayMonth(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }

  /// Formats a date as shown in the header (e.g. "Mon, Aug 17")
  static String formatHeaderDate(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
  }
}
