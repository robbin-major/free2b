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

  static DateTime? effectiveEventEndDate(EventModel event) {
    final DateTime? startDate = parseEventDateTime(event.startDate);
    if (startDate == null) {
      return null;
    }

    final String endValue = event.endDate?.trim() ?? '';
    final DateTime? fullEndDate = parseEventDateTime(endValue);
    if (fullEndDate != null) {
      return fullEndDate;
    }

    // Some imported events provide endTime without repeating the event date.
    // Anchor that local wall-clock time to the start date instead of silently
    // falling back to the start time.
    for (final DateFormat format in <DateFormat>[
      DateFormat('hh:mm a'),
      DateFormat('h:mm a'),
      DateFormat('HH:mm'),
    ]) {
      final DateTime? parsedTime = format.tryParse(endValue);
      if (parsedTime != null) {
        return DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      }
    }

    return startDate;
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
    // Event strings are stored as local wall-clock values. Normalize an
    // injected UTC clock before comparing it with those local values.
    final DateTime currentTime = (now ?? DateTime.now()).toLocal();

    return events.any((EventModel event) {
      if (!attendingEventIds.contains(event.eventID)) {
        return false;
      }

      final DateTime? effectiveEndDate = effectiveEventEndDate(event);
      if (effectiveEndDate == null) {
        return false;
      }

      final String effectiveValue = (event.endDate?.trim().isNotEmpty ?? false)
          ? event.endDate!.trim()
          : event.startDate?.trim() ?? '';
      final bool hasExplicitTime = effectiveValue.contains(':');

      if (!hasExplicitTime) {
        return !_startOfDay(effectiveEndDate)
            .isBefore(_startOfDay(currentTime));
      }

      return effectiveEndDate.isAfter(currentTime);
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
