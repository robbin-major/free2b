enum EventStatus {
  APPROVAL("APPROVAL"),
  PENDING("PENDING");

  final String eventType;

  const EventStatus(this.eventType);
}
