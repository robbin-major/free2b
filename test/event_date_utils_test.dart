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

    test('expires the October 2 attendance after its local end time', () {
      final EventModel event = EventModel(
        eventID: 'october-2',
        startDate: '02-10-2026 09:00 AM',
        endDate: '02-10-2026 11:30 AM',
      );

      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'october-2'},
          now: DateTime(2026, 10, 2, 11, 29),
        ),
        isTrue,
      );
      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'october-2'},
          now: DateTime(2026, 10, 2, 11, 30),
        ),
        isFalse,
      );
      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'october-2'},
          now: DateTime(2026, 10, 2, 11, 31),
        ),
        isFalse,
      );
    });

    test('anchors an end-time-only value to the local start date', () {
      final EventModel event = EventModel(
        eventID: 'same-day',
        startDate: '02-10-2026 09:00 AM',
        endDate: '11:30 AM',
      );

      expect(
        EventDateUtils.effectiveEventEndDate(event),
        DateTime(2026, 10, 2, 11, 30),
      );
      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'same-day'},
          now: DateTime(2026, 10, 2, 12),
        ),
        isFalse,
      );
    });

    test('keeps a date-only attended event gold through its local day', () {
      final EventModel event = EventModel(
        eventID: 'date-only',
        startDate: '02-10-2026',
      );

      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'date-only'},
          now: DateTime(2026, 10, 2, 23, 59),
        ),
        isTrue,
      );
      expect(
        EventDateUtils.hasActiveAttendedEvent(
          events: <EventModel>[event],
          attendingEventIds: <String>{'date-only'},
          now: DateTime(2026, 10, 3),
        ),
        isFalse,
      );
    });
  });
}
