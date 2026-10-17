import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
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

  static String? formatEventDateForLocale(String? eventDate, String locale) {
    final DateTime? parsedDate = parseEventDateTime(eventDate);
    if (parsedDate == null) {
      return null;
    }

    return DateFormat.yMMMMd(locale).format(parsedDate);
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

  static bool hasActiveAttendedEvent({
    required Iterable<EventModel> events,
    required Set<String> attendingEventIds,
    DateTime? now,
  }) {
    final DateTime currentTime = now ?? DateTime.now();

    return events.any((EventModel event) {
      if (!attendingEventIds.contains(event.eventID)) {
        return false;
      }

      final DateTime? startDate = parseEventDateTime(event.startDate);
      if (startDate == null) {
        return false;
      }

      final DateTime effectiveEndDate =
          parseEventDateTime(event.endDate) ?? startDate;
      return !effectiveEndDate.isBefore(currentTime);
    });
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
