import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter/foundation.dart';

const bool _performanceInstrumentationEnabled = kDebugMode || kProfileMode;

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
    music, dance, theater, visualArts, film, booksLiterature, familyKids,
    festivalsParades, community, workshopsClasses, sportsRecreation,
    natureOutdoors, historyCulture,
  ];
}

/// One inspectable piece of evidence used by the interest classifier.
class InterestMatchReason {
  const InterestMatchReason({
    required this.interest,
    required this.source,
    required this.value,
  });

  final String interest;
  final String source;
  final String value;

  @override
  String toString() => '$source: "$value"';
}

abstract final class EventInterestClassifier {
  static int _classificationInvocationCount = 0;
  static int _classificationElapsedMicroseconds = 0;

  static int get classificationInvocationCount =>
      _classificationInvocationCount;

  static Duration get classificationElapsed => Duration(
        microseconds: _classificationElapsedMicroseconds,
      );

  static void resetPerformanceMetrics() {
    _classificationInvocationCount = 0;
    _classificationElapsedMicroseconds = 0;
  }

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

  static const Set<String> _ignoredCategories = <String>{
    'chicago parks district', 'chicago park district', 'chicago public library',
    'cpl', 'dcase', 'lgbtq friendly', 'accessible', 'senior', 'veterans',
    'downtown', 'arts and culture',
  };

  // Exact source labels are deliberately narrower than free-text matching.
  static const Map<String, List<String>> _sourceTypeMap = <String, List<String>>{
    'film screenings': <String>[Free2bInterest.film],
    'writing and poetry': <String>[Free2bInterest.booksLiterature],
    'author events': <String>[Free2bInterest.booksLiterature],
    'book clubs': <String>[Free2bInterest.booksLiterature],
    'story time': <String>[Free2bInterest.booksLiterature, Free2bInterest.familyKids],
    'workshops': <String>[Free2bInterest.workshopsClasses],
    'classes': <String>[Free2bInterest.workshopsClasses],
  };

  static const Map<String, List<String>> _sourceTagMap = <String, List<String>>{
    'music': <String>[Free2bInterest.music],
    'dance': <String>[Free2bInterest.dance],
    'theater': <String>[Free2bInterest.theater],
    'theatre': <String>[Free2bInterest.theater],
    'film': <String>[Free2bInterest.film],
    'exhibitions': <String>[Free2bInterest.visualArts],
    'public art': <String>[Free2bInterest.visualArts],
    'festivals': <String>[Free2bInterest.festivalsParades],
    'parades': <String>[Free2bInterest.festivalsParades],
    'family': <String>[Free2bInterest.familyKids],
  };

  static const Map<String, List<String>> _titleKeywords = <String, List<String>>{
    Free2bInterest.music: <String>['music', 'concert', 'jazz', 'blues', 'hip hop', 'gospel', 'orchestra', 'symphony', 'choir', 'band', 'dj'],
    Free2bInterest.dance: <String>['dance', 'dancing', 'ballet', 'salsa', 'stepping', 'ballroom', 'choreography'],
    Free2bInterest.theater: <String>['theater', 'theatre', 'theatrical', 'stage play', 'stage production', 'acting', 'drama', 'dramatic performance', 'musical theater', 'musical theatre'],
    Free2bInterest.visualArts: <String>['visual art', 'painting', 'drawing', 'sculpture', 'sculptural', 'gallery', 'exhibition', 'exhibit', 'photography', 'mural', 'ceramics', 'printmaking'],
    Free2bInterest.film: <String>['film', 'movie', 'cinema', 'screening', 'documentary'],
    Free2bInterest.booksLiterature: <String>['book', 'reading', 'author', 'poetry', 'poet', 'writing', 'literature', 'storytime', 'story time', 'book club'],
    Free2bInterest.familyKids: <String>['family', 'kids', 'children', 'youth', 'teen', 'teens', 'toddler', 'toddlers', 'storytime', 'story time'],
    Free2bInterest.festivalsParades: <String>['festival', 'street fest', 'parade'],
    Free2bInterest.community: <String>['neighborhood', 'civic gathering', 'community meeting', 'community gathering'],
    Free2bInterest.workshopsClasses: <String>['workshop', 'class', 'lesson', 'course', 'training', 'hands on workshop', 'maker workshop'],
    Free2bInterest.sportsRecreation: <String>['sports', 'basketball', 'football', 'soccer', 'baseball', 'softball', 'tennis', 'volleyball', 'fitness', 'workout', 'swimming', 'running'],
    Free2bInterest.natureOutdoors: <String>['nature', 'naturalist', 'garden', 'gardening', 'outdoors', 'birding', 'hiking', 'ecology', 'wildlife'],
    Free2bInterest.historyCulture: <String>['history', 'historical', 'heritage', 'cultural history', 'cultural heritage', 'museum'],
  };

  // Description evidence must describe a specific activity, not merely mention a
  // generic concept such as art, family, community, culture, show, or learning.
  static const Map<String, List<String>> _descriptionKeywords = <String, List<String>>{
    Free2bInterest.music: <String>['live music', 'jazz concert', 'blues concert', 'musical performance', 'orchestra concert'],
    Free2bInterest.dance: <String>['dance performance', 'dance workshop', 'ballet performance', 'dance class'],
    Free2bInterest.theater: <String>['stage play', 'stage production', 'dramatic performance', 'musical theater', 'musical theatre'],
    Free2bInterest.visualArts: <String>['art exhibition', 'visual arts exhibition', 'painting workshop', 'sculpture exhibition', 'photography exhibition'],
    Free2bInterest.film: <String>['film screening', 'movie screening', 'documentary screening'],
    Free2bInterest.booksLiterature: <String>['author reading', 'poetry reading', 'book discussion', 'book club'],
    Free2bInterest.festivalsParades: <String>['street festival', 'neighborhood festival', 'cultural festival'],
    Free2bInterest.community: <String>['community meeting', 'community gathering', 'civic meeting', 'neighborhood gathering'],
    Free2bInterest.workshopsClasses: <String>['hands on workshop', 'maker workshop', 'instructional workshop', 'training course'],
    Free2bInterest.sportsRecreation: <String>['basketball game', 'soccer game', 'fitness class', 'sports clinic'],
    Free2bInterest.natureOutdoors: <String>['nature walk', 'birding walk', 'garden tour', 'outdoor hike'],
    Free2bInterest.historyCulture: <String>['historical lecture', 'history lecture', 'cultural heritage', 'heritage celebration'],
  };

  static Set<String> classify(EventModel event) {
    final Stopwatch? stopwatch =
        _performanceInstrumentationEnabled ? (Stopwatch()..start()) : null;
    final Map<String, List<InterestMatchReason>> matches = explain(event);
    final Set<String> interests = Set<String>.from(
      Free2bInterest.values.where(matches.containsKey),
    );

    if (stopwatch != null) {
      stopwatch.stop();
      _classificationInvocationCount++;
      _classificationElapsedMicroseconds += stopwatch.elapsedMicroseconds;
      if (_classificationInvocationCount % 100 == 0) {
        debugPrint(
          '[performance] Interest classification: '
          'calls=$_classificationInvocationCount, '
          'total=${classificationElapsed.inMilliseconds}ms',
        );
      }
    }

    return interests;
  }

  /// Development/test helper showing every accepted match and its evidence.
  static Map<String, List<InterestMatchReason>> explain(EventModel event) {
    final result = <String, List<InterestMatchReason>>{};
    void add(String interest, String source, String value) {
      result.putIfAbsent(interest, () => <InterestMatchReason>[]).add(
        InterestMatchReason(interest: interest, source: source, value: value),
      );
    }

    for (final category in event.category ?? const <Category>[]) {
      final raw = category.categoryName ?? '';
      final normalized = _normalize(raw);
      if (_ignoredCategories.contains(normalized)) continue;
      final interest = _adminCategoryMap[normalized];
      if (interest != null) add(interest, 'Admin category', raw);
    }
    _applyStructured(event.sourceTypes, _sourceTypeMap, 'source type', add);
    _applyStructured(event.sourceTags, _sourceTagMap, 'source tag', add);
    for (final audience in event.audiences ?? const <String>[]) {
      final normalized = _normalize(audience);
      if (_containsAny(normalized, const <String>['family', 'families', 'kids', 'children', 'youth', 'teen', 'teens', 'toddler', 'toddlers'])) {
        add(Free2bInterest.familyKids, 'source audience', audience);
      }
    }
    _applyKeywords(event.title, _titleKeywords, 'title phrase', add);
    _applyKeywords((event.description ?? const <String>[]).join(' '), _descriptionKeywords, 'description phrase', add);
    return result;
  }

  static bool matches(EventModel event, String interest) => classify(event).contains(interest);

  static void _applyStructured(List<String>? values, Map<String, List<String>> mapping, String source, void Function(String, String, String) add) {
    for (final value in values ?? const <String>[]) {
      for (final interest in mapping[_normalize(value)] ?? const <String>[]) {
        add(interest, source, value);
      }
    }
  }

  static void _applyKeywords(String? raw, Map<String, List<String>> mapping, String source, void Function(String, String, String) add) {
    final text = _normalize(raw);
    for (final entry in mapping.entries) {
      for (final phrase in entry.value) {
        if (_containsPhrase(text, phrase)) add(entry.key, source, phrase);
      }
    }
  }

  static bool _containsAny(String text, List<String> phrases) => phrases.any((phrase) => _containsPhrase(text, phrase));
  static bool _containsPhrase(String text, String phrase) => ' $text '.contains(' ${_normalize(phrase)} ');
  static String _normalize(String? value) => (value ?? '').toLowerCase().replaceAll('&', ' and ').replaceAll(RegExp(r'[^a-z0-9]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
