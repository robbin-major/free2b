import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/event_interest_classifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventInterestClassifier', () {
    test('normalizes existing Admin categories and ignores provider facets', () {
      final event = EventModel(
        category: <Category>[
          Category(categoryName: 'Live music'),
          Category(categoryName: 'Kid friendly'),
          Category(categoryName: 'Chicago Parks District'),
          Category(categoryName: 'Accessible'),
        ],
      );

      expect(
        EventInterestClassifier.classify(event),
        <String>{Free2bInterest.music, Free2bInterest.familyKids},
      );
    });

    test('classifies phrases without requiring a category', () {
      final event = EventModel(
        title: 'Neighborhood author reading',
        description: const <String>['A poetry discussion at the library.'],
      );

      expect(
        EventInterestClassifier.classify(event),
        containsAll(<String>[
          Free2bInterest.booksLiterature,
          Free2bInterest.community,
        ]),
      );
    });

    test('supports multiple interests from categories and text', () {
      final event = EventModel(
        title: "Children's ballet class",
        category: <Category>[Category(categoryName: 'Dance')],
        audiences: const <String>['Children'],
        sourceTypes: const <String>['Classes'],
      );

      expect(
        EventInterestClassifier.classify(event),
        containsAll(<String>[
          Free2bInterest.dance,
          Free2bInterest.familyKids,
          Free2bInterest.workshopsClasses,
        ]),
      );
    });

    test('uses all manually assigned categories', () {
      final event = EventModel(
        category: <Category>[
          Category(categoryName: 'Concerts'),
          Category(categoryName: 'Festival'),
          Category(categoryName: 'Sports'),
        ],
      );

      expect(
        EventInterestClassifier.classify(event),
        <String>{
          Free2bInterest.music,
          Free2bInterest.festivalsParades,
          Free2bInterest.sportsRecreation,
        },
      );
    });

    test('avoids provider and substring false positives', () {
      final event = EventModel(
        title: 'Parking information and display update',
        description: const <String>['Hosted by Chicago Park District.'],
        source: 'Chicago Park District',
      );

      expect(EventInterestClassifier.classify(event), isEmpty);
    });

    test('does not treat a generic musical reference as theater', () {
      final event = EventModel(title: 'Musical instruments open house');

      expect(
        EventInterestClassifier.classify(event),
        isNot(contains(Free2bInterest.theater)),
      );
    });

    test('classifies a youth basketball class into three interests', () {
      final event = EventModel(title: 'Youth basketball class');

      expect(
        EventInterestClassifier.classify(event),
        containsAll(<String>[
          Free2bInterest.sportsRecreation,
          Free2bInterest.familyKids,
          Free2bInterest.workshopsClasses,
        ]),
      );
    });

    test('Memory Cafe ignores incidental activities in its description', () {
      final event = EventModel(
        title: 'Memory Café',
        description: const <String>[
          'A relaxed place for people with memory loss and their care partners. '
              'Activities may include games, arts and crafts, and music. Friends, '
              'family and community allies are welcome.',
        ],
        sourceTypes: const <String>['Workshops'],
        audiences: const <String>['Adults', 'Seniors'],
      );

      expect(EventInterestClassifier.classify(event),
          <String>{Free2bInterest.workshopsClasses});
    });

    test('film festival venue name does not imply theater or culture', () {
      final event = EventModel(
        title: 'Asian Pop-Up Festival Screening',
        sourceTags: const <String>['All', 'Chicago Cultural Center', 'Film'],
        venue: 'Chicago Cultural Center, Claudia Cassidy Theater',
      );

      expect(EventInterestClassifier.classify(event), <String>{
        Free2bInterest.film,
        Free2bInterest.festivalsParades,
      });
    });

    test('film talkback remains film only', () {
      final event = EventModel(
        title: 'Problemista Screening and Talkback',
        sourceTags: const <String>['All', 'Chicago Cultural Center', 'Film'],
        venue: 'Chicago Cultural Center, Claudia Cassidy Theater',
      );

      expect(EventInterestClassifier.classify(event),
          <String>{Free2bInterest.film});
    });

    test('sculptural lecture is visual arts, not theater or workshop', () {
      final event = EventModel(
        title: 'Sculptural Portals lecture',
        sourceTags: const <String>[
          'All', 'Chicago Cultural Center', 'Exhibitions',
          'Lectures & Workshops',
        ],
        venue: 'Chicago Cultural Center, Claudia Cassidy Theater',
      );

      expect(EventInterestClassifier.classify(event),
          <String>{Free2bInterest.visualArts});
    });

    test('explains accepted evidence without exposing it to production UI', () {
      final event = EventModel(
        title: 'Ballet Workshop for Kids',
        category: <Category>[Category(categoryName: 'Dance')],
        audiences: const <String>['Kids'],
      );
      final explanation = EventInterestClassifier.explain(event);

      expect(explanation[Free2bInterest.dance]!.map((reason) => reason.source),
          contains('Admin category'));
      expect(explanation[Free2bInterest.familyKids]!.map((reason) => reason.source),
          contains('source audience'));
      expect(explanation[Free2bInterest.workshopsClasses]!.single.toString(),
          'title phrase: "workshop"');
    });
  });
}
