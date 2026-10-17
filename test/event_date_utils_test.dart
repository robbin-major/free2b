import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  test('formats event dates in the requested locale without changing day', () {
    expect(
      EventDateUtils.formatEventDateForLocale('17-10-2026', 'es_ES'),
      allOf(contains('17'), contains('octubre'), contains('2026')),
    );
    expect(
      EventDateUtils.formatEventDateForLocale('17-10-2026', 'en_US'),
      allOf(contains('October'), contains('17'), contains('2026')),
    );
  });

  group('EventDateUtils.hasActiveAttendedEvent', () {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy hh:mm a');

    test('ignores unrelated active events on a date with ended attendance', () {
      final DateTime now = DateTime(2026, 10, 17, 12);
      final List<EventModel> events = <EventModel>[
        EventModel(
          eventID: 'attended-ended',
          startDate: dateFormat.format(DateTime(2026, 10, 17, 8)),
          endDate: dateFormat.format(DateTime(2026, 10, 17, 10)),
        ),
        EventModel(
          eventID: 'not-attending',
          startDate: dateFormat.format(DateTime(2026, 10, 17, 11)),
          endDate: dateFormat.format(DateTime(2026, 10, 17, 13)),
        ),
      ];

      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: events,
          attendingEventIds: <String>{'attended-ended'},
          now: now,
        ),
        isFalse,
      );
    });

    test('keeps a date gold when another attended event is still active', () {
      final DateTime now = DateTime(2026, 10, 17, 12);
      final List<EventModel> events = <EventModel>[
        EventModel(
          eventID: 'ended',
          startDate: dateFormat.format(DateTime(2026, 10, 17, 8)),
          endDate: dateFormat.format(DateTime(2026, 10, 17, 10)),
        ),
        EventModel(
          eventID: 'active',
          startDate: dateFormat.format(DateTime(2026, 10, 17, 11)),
          endDate: dateFormat.format(DateTime(2026, 10, 17, 13)),
        ),
      ];

      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: events,
          attendingEventIds: <String>{'ended', 'active'},
          now: now,
        ),
        isTrue,
      );
    });

    test('uses the start time when an event has no end time', () {
      final DateTime now = DateTime(2026, 10, 17, 12);
      final EventModel upcomingEvent = EventModel(
        eventID: 'upcoming',
        startDate: dateFormat.format(DateTime(2026, 10, 18, 12)),
      );
      final EventModel endedEvent = EventModel(
        eventID: 'ended',
        startDate: dateFormat.format(DateTime(2026, 10, 17, 11)),
      );

      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[upcomingEvent],
          attendingEventIds: <String>{'upcoming'},
          now: now,
        ),
        isTrue,
      );
      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[endedEvent],
          attendingEventIds: <String>{'ended'},
          now: now,
        ),
        isFalse,
      );
    });
  });
}