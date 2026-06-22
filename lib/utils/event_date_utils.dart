import 'package:intl/intl.dart';

class EventDateUtils {
  static const int recentPastWindowDays = 30;

  static DateTime? parseEventDateTime(String? startDate) {
    if (startDate == null || startDate.trim().isEmpty) {
      return null;
    }

    final String value = startDate.trim();
    final List<DateFormat> formats = [
      DateFormat('dd-MM-yyyy hh:mm a'),
      DateFormat('dd-MM-yyyy'),
    ];

    for (final DateFormat format in formats) {
      final DateTime? parsed = format.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  static bool isWithinCalendarVisibilityWindow(DateTime eventDate) {
    final DateTime today = _startOfDay(DateTime.now());
    final DateTime earliestVisibleDay =
        today.subtract(const Duration(days: recentPastWindowDays));
    final DateTime eventDay = _startOfDay(eventDate);

    return !eventDay.isBefore(earliestVisibleDay);
  }

  static bool hasEventEnded(DateTime eventDateTime) {
    return eventDateTime.isBefore(DateTime.now());
  }

  static bool isRecentPastEvent(DateTime eventDate) {
    final DateTime today = _startOfDay(DateTime.now());
    final DateTime earliestVisibleDay =
        today.subtract(const Duration(days: recentPastWindowDays));
    final DateTime eventDay = _startOfDay(eventDate);

    return eventDay.isBefore(today) && !eventDay.isBefore(earliestVisibleDay);
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
