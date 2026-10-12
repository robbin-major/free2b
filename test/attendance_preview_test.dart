import 'package:flutter_template/modules/dashboard/home/presentation/attendance_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('attendance state only matches the current event', () {
    expect(
      isEventAttending(
        attendingEventIds: const <String>['event-1', 'event-2'],
        eventId: 'event-2',
      ),
      isTrue,
    );
    expect(
      isEventAttending(
        attendingEventIds: const <String>['event-1', 'event-2'],
        eventId: 'event-3',
      ),
      isFalse,
    );
  });

  test('shows the first-attendee prompt before joining', () {
    expect(
      attendancePreviewMessage(isAttending: false),
      firstAttendeePrompt,
    );
  });

  test('hides the first-attendee prompt after joining', () {
    expect(attendancePreviewMessage(isAttending: true), isNull);
  });
}
