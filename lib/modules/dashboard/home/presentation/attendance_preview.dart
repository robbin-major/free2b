const String firstAttendeePrompt =
    'Be one of the first to mark yourself attending';

bool isEventAttending({
  required Iterable<String> attendingEventIds,
  required String eventId,
}) {
  return eventId.isNotEmpty && attendingEventIds.contains(eventId);
}

String? attendancePreviewMessage({required bool isAttending}) {
  return isAttending ? null : firstAttendeePrompt;
}
