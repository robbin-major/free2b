import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/event_maps.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('eventMapDestination', () {
    test('prefers venue and complete address over coordinates', () {
      final EventModel event = EventModel(
        venue: 'Chicago Cultural Center',
        address: '78 E Washington St',
        city: 'Chicago',
        state: 'IL',
        zipCode: '60602',
        country: 'United States',
      );

      expect(
        eventMapDestination(
          event,
          fallbackLatitude: 41.8838,
          fallbackLongitude: -87.6257,
        ),
        'Chicago Cultural Center, 78 E Washington St, Chicago, IL 60602',
      );
    });

    test('uses complete address when venue is unavailable', () {
      final EventModel event = EventModel(
        address: '400 S State St',
        city: 'Chicago',
        state: 'Illinois',
        zipCode: '60605',
      );

      expect(
        eventMapDestination(event),
        '400 S State St, Chicago, Illinois 60605',
      );
    });

    test('falls back to coordinates only without human-readable location', () {
      expect(
        eventMapDestination(
          EventModel(),
          fallbackLatitude: 41.8781,
          fallbackLongitude: -87.6298,
        ),
        '41.8781,-87.6298',
      );
    });

    test('properly URL-encodes the Google Maps destination', () {
      final EventModel event = EventModel(
        venue: 'Harold Washington Library Center',
        address: '400 S State St',
        city: 'Chicago',
        state: 'IL',
        zipCode: '60605',
      );
      final Uri uri = googleMapsDirectionsUri(event);

      expect(uri.queryParameters['api'], '1');
      expect(
        uri.queryParameters['destination'],
        'Harold Washington Library Center, 400 S State St, Chicago, IL 60605',
      );
      expect(uri.toString(), contains('destination='));
      expect(uri.toString(), isNot(contains(' ')));
    });
  });
}
