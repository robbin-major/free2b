import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';

String eventMapDestination(
  EventModel event, {
  double? fallbackLatitude,
  double? fallbackLongitude,
}) {
  final String state = (event.state ?? '').trim();
  final String zipCode = (event.zipCode ?? '').trim();
  final String stateAndZip = <String>[state, zipCode]
      .where((String value) => value.isNotEmpty)
      .join(' ');
  final String country = (event.country ?? '').trim();
  final bool isUnitedStates = <String>{'us', 'usa', 'united states'}
      .contains(country.toLowerCase());
  final List<String> parts = <String?>[
    event.venue,
    event.address,
    event.aptSuiteOther,
    event.city,
    stateAndZip,
    if (!isUnitedStates) country,
  ]
      .whereType<String>()
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .fold<List<String>>(<String>[], (List<String> values, String value) {
    if (!values.any(
      (String existing) => existing.toLowerCase() == value.toLowerCase(),
    )) {
      values.add(value);
    }
    return values;
  });

  if (parts.isNotEmpty) return parts.join(', ');
  if (fallbackLatitude != null && fallbackLongitude != null) {
    return '$fallbackLatitude,$fallbackLongitude';
  }
  return '';
}

Uri googleMapsSearchUri(
  EventModel event, {
  double? fallbackLatitude,
  double? fallbackLongitude,
}) {
  return Uri.https(
    'www.google.com',
    '/maps/search/',
    <String, String>{
      'api': '1',
      'query': eventMapDestination(
        event,
        fallbackLatitude: fallbackLatitude,
        fallbackLongitude: fallbackLongitude,
      ),
    },
  );
}

Uri googleMapsDirectionsUri(
  EventModel event, {
  double? fallbackLatitude,
  double? fallbackLongitude,
}) {
  return Uri.https(
    'www.google.com',
    '/maps/dir/',
    <String, String>{
      'api': '1',
      'destination': eventMapDestination(
        event,
        fallbackLatitude: fallbackLatitude,
        fallbackLongitude: fallbackLongitude,
      ),
    },
  );
}
