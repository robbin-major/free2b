import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/modules/dashboard/map/presentation/discovery_map_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Discover map state', () {
    test('embedded map remains disabled unless explicitly enabled', () {
      expect(discoveryMapEnabled, isFalse);
    });

    test('list remains the first view mode', () {
      expect(DiscoveryViewMode.values.first, DiscoveryViewMode.list);
    });

    test('uses event ID as the stable marker identity', () {
      expect(
        discoveryEventKey(EventModel(eventID: 'event-42')),
        'event:event-42',
      );
    });

    test('falls back to source identity for imported events', () {
      expect(
        discoveryEventKey(
          EventModel(source: 'DCASE', sourceId: 'source-42'),
        ),
        'source:DCASE:source-42',
      );
    });
  });
}
