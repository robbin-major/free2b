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
  });
}
