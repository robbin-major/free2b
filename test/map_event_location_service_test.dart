import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/modules/dashboard/map/data/map_event_location_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel coordinates', () {
    test('reads top-level latitude and longitude values', () {
      final EventModel event = EventModel.fromJson(<String, dynamic>{
        'title': 'Mapped event',
        'latitude': '41.8781',
        'longitude': -87.6298,
      });

      expect(event.latitude, 41.8781);
      expect(event.longitude, -87.6298);
    });

    test('reads nested coordinate maps', () {
      final EventModel event = EventModel.fromJson(<String, dynamic>{
        'title': 'Nested event',
        'location': <String, dynamic>{
          'lat': 41.89,
          'lng': -87.62,
        },
      });

      expect(event.latitude, 41.89);
      expect(event.longitude, -87.62);
    });
  });

  group('MapEventLocationService ZIP normalization', () {
    test('keeps only the first five US ZIP digits', () {
      final MapEventLocationService service = MapEventLocationService();

      expect(service.normalizeZip('60601-1234'), '60601');
      expect(service.normalizeZip(' 90a210 '), '90210');
      expect(service.normalizeZip('abc'), '');
    });
  });
}
