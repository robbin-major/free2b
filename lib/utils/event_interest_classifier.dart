import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';

abstract final class Free2bInterest {
  static const String music = 'Music';
  static const String dance = 'Dance';
  static const String theater = 'Theater';
  static const String visualArts = 'Visual Arts';
  static const String film = 'Film';
  static const String booksLiterature = 'Books & Literature';
  static const String familyKids = 'Family & Kids';
  static const String festivalsParades = 'Festivals & Parades';
  static const String community = 'Community';
  static const String workshopsClasses = 'Workshops & Classes';
  static const String sportsRecreation = 'Sports & Recreation';
  static const String natureOutdoors = 'Nature & Outdoors';
  static const String historyCulture = 'History & Culture';

  static const List<String> values = <String>[
    music,
    dance,
    theater,
    visualArts,
    film,
    booksLiterature,
    familyKids,
    festivalsParades,
    community,
    workshopsClasses,
    sportsRecreation,
    natureOutdoors,
    historyCulture,
  ];
}

abstract final class EventInterestClassifier {
  static const Map<String, String> _adminCategoryMap = <String, String>{
    'live music': Free2bInterest.music,
    'concerts': Free2bInterest.music,
    'dance': Free2bInterest.dance,
    'theater': Free2bInterest.theater,
    'exhibition': Free2bInterest.visualArts,
    'mural': Free2bInterest.visualArts,
    'movies in the park': Free2bInterest.film,
    'kid friendly': Free2bInterest.familyKids,
    'festival': Free2bInterest.festivalsParades,
    'street fest': Free2bInterest.festivalsParades,
    'parade': Free2bInterest.festivalsParades,
    'air and water show': Free2bInterest.festivalsParades,
    'community enrichment': Free2bInterest.community,
    'sports': Free2bInterest.sportsRecreation,
    'workouts': Free2bInterest.sportsRecreation,
    'cultural center events': Free2bInterest.historyCulture,
  };

  static const Set<String> _providerCategories = <String>{
    'chicago parks district',
    'chicago park district',
    'chicago public library',
    'cpl',
    'dcase',
  };

  static const Set<String> _nonInterestFacets = <String>{
    'lgbtq friendly',
    'accessible',
    'senior',
    'veterans',
    'downtown',
  };

  static const Map<String, List<String>> _keywords = <String, List<String>>{
    Free2bInterest.music: <String>[
      'music', 'live music', 'concert', 'concerts', 'jazz', 'blues',
      'hip hop', 'rap', 'r and b', 'rhythm and blues', 'soul', 'gospel',
      'orchestra', 'symphony', 'choir', 'choral', 'singer', 'singing', 'band',
      'musician', 'dj', 'deejay',
    ],
    Free2bInterest.dance: <String>[
      'dance', 'dancing', 'dancer', 'ballet', 'salsa', 'stepping', 'ballroom',
      'choreography', 'choreographer', 'tap dance', 'modern dance',
      'contemporary dance',
    ],
    Free2bInterest.theater: <String>[
      'theater', 'theatre', 'theatrical', 'stage play', 'stage performance',
      'acting', 'actor', 'drama', 'dramatic performance', 'musical theatre',
      'musical theater', 'broadway musical', 'stage musical',
    ],
    Free2bInterest.visualArts: <String>[
      'visual art', 'visual arts', 'painting', 'drawing', 'sculpture', 'gallery',
      'exhibition', 'exhibit', 'photography', 'photographer', 'mural',
      'ceramics', 'printmaking', 'craft',
      'crafts',
    ],
    Free2bInterest.film: <String>[
      'film', 'films', 'movie', 'movies', 'cinema', 'screening', 'documentary',
    ],
    Free2bInterest.booksLiterature: <String>[
      'book', 'books', 'reading', 'author', 'author talk', 'poetry', 'poet',
      'writing', 'writer', 'literature', 'literary', 'storytime', 'story time',
      'book club',
    ],
    Free2bInterest.familyKids: <String>[
      'family', 'families', 'kid', 'kids', 'child', 'children', 'youth', 'teen',
      'teens', 'toddler', 'toddlers', 'storytime', 'story time',
    ],
    Free2bInterest.festivalsParades: <String>[
      'festival', 'festivals', 'fest', 'street fest', 'fair', 'parade',
      'celebration',
    ],
    Free2bInterest.community: <String>[
      'community', 'neighborhood', 'civic', 'community meeting',
      'community gathering',
    ],
    Free2bInterest.workshopsClasses: <String>[
      'workshop', 'workshops', 'class', 'classes', 'lesson', 'lessons', 'learn',
      'learning', 'training', 'seminar', 'maker', 'hands on',
    ],
    Free2bInterest.sportsRecreation: <String>[
      'sports', 'basketball', 'football', 'soccer', 'baseball', 'softball',
      'tennis', 'volleyball', 'fitness', 'workout', 'workouts', 'recreation',
      'recreational', 'swimming', 'swim', 'running',
    ],
    Free2bInterest.natureOutdoors: <String>[
      'nature', 'naturalist', 'garden', 'gardening', 'outdoors', 'outdoor',
      'birding', 'birds', 'hiking', 'ecology', 'ecological', 'wildlife',
      'environmental', 'environment',
    ],
    Free2bInterest.historyCulture: <String>[
      'history', 'historical', 'heritage', 'culture', 'cultural', 'museum',
      'tradition', 'traditional', 'cultural center',
    ],
  };

  static Set<String> classify(EventModel event) {
    final Set<String> interests = <String>{};

    for (final Category category in event.category ?? const <Category>[]) {
      final String normalized = _normalize(category.categoryName);
      if (_providerCategories.contains(normalized) ||
          _nonInterestFacets.contains(normalized) ||
          normalized == 'arts and culture') {
        continue;
      }
      final String? interest = _adminCategoryMap[normalized];
      if (interest != null) interests.add(interest);
    }

    final String sourceMetadata = _normalize(<String>[
      ...?event.sourceTypes,
      ...?event.sourceTags,
      ...?event.audiences,
      ...?event.languages,
      event.programName ?? '',
      event.type ?? '',
    ].join(' '));
    _applyKeywords(sourceMetadata, interests);

    final String eventText = _normalize(<String>[
      event.title ?? '',
      ...?event.description,
      event.venue ?? '',
    ].join(' '));
    _applyKeywords(eventText, interests);

    return Set<String>.from(
      Free2bInterest.values.where(interests.contains),
    );
  }

  static bool matches(EventModel event, String interest) {
    return classify(event).contains(interest);
  }

  static void _applyKeywords(String text, Set<String> interests) {
    if (text.isEmpty) return;
    final String padded = ' $text ';
    for (final MapEntry<String, List<String>> entry in _keywords.entries) {
      if (entry.value.any((keyword) => padded.contains(' $keyword '))) {
        interests.add(entry.key);
      }
    }
  }

  static String _normalize(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll('&', ' and ')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
