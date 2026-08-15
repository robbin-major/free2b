import 'dart:convert';

import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapEventLocation {
  const MapEventLocation({
    required this.event,
    required this.position,
  });

  final EventModel event;
  final LatLng position;
}

enum ZipLookupStatus { empty, invalid, found, notFound, error }

class ZipLookupResult {
  const ZipLookupResult({
    required this.status,
    this.position,
    this.message,
  });

  final ZipLookupStatus status;
  final LatLng? position;
  final String? message;
}

class MapEventLocationService {
  static const String _coordinateCachePrefix = 'map_coordinate_cache_v1';
  static const String _zipCachePrefix = 'map_zip_cache_v1';

  Future<List<MapEventLocation>> resolveEventLocations(
    List<EventModel> events,
  ) async {
    final List<MapEventLocation> resolved = <MapEventLocation>[];

    for (final EventModel event in events) {
      final LatLng? position = await resolveEventLocation(event);
      if (position != null) {
        resolved.add(MapEventLocation(event: event, position: position));
      }
    }

    return resolved;
  }

  Future<LatLng?> resolveEventLocation(EventModel event) async {
    final LatLng? stored = _storedEventPosition(event);
    if (stored != null) {
      return stored;
    }

    final String query = _eventLocationQuery(event);
    if (query.isEmpty) {
      return null;
    }

    final String cacheKey = _eventCacheKey(event, query);
    final LatLng? cached = await _readCachedPosition(cacheKey);
    if (cached != null) {
      return cached;
    }

    final LatLng? geocoded = await _geocode(query);
    if (geocoded != null) {
      await _writeCachedPosition(cacheKey, geocoded);
    }

    return geocoded;
  }

  Future<ZipLookupResult> resolveZipCode(String rawZipCode) async {
    final String zipCode = normalizeZip(rawZipCode);
    if (zipCode.isEmpty) {
      return const ZipLookupResult(status: ZipLookupStatus.empty);
    }
    if (zipCode.length != 5) {
      return const ZipLookupResult(
        status: ZipLookupStatus.invalid,
        message: 'Enter a 5-digit US ZIP code.',
      );
    }

    final String cacheKey = '$_zipCachePrefix:$zipCode';
    final LatLng? cached = await _readCachedPosition(cacheKey);
    if (cached != null) {
      return ZipLookupResult(
        status: ZipLookupStatus.found,
        position: cached,
      );
    }

    try {
      final LatLng? geocoded = await _geocode('$zipCode, United States');
      if (geocoded == null) {
        return const ZipLookupResult(
          status: ZipLookupStatus.notFound,
          message: 'No map location found for that ZIP code.',
        );
      }
      await _writeCachedPosition(cacheKey, geocoded);
      return ZipLookupResult(
        status: ZipLookupStatus.found,
        position: geocoded,
      );
    } catch (error) {
      return ZipLookupResult(
        status: ZipLookupStatus.error,
        message: '$error',
      );
    }
  }

  String normalizeZip(String? value) {
    final String digitsOnly = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length > 5 ? digitsOnly.substring(0, 5) : digitsOnly;
  }

  LatLng? _storedEventPosition(EventModel event) {
    final double? latitude = event.latitude;
    final double? longitude = event.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }
    if (latitude < -90 || latitude > 90 || longitude < -180 || longitude > 180) {
      return null;
    }
    return LatLng(latitude, longitude);
  }

  String _eventLocationQuery(EventModel event) {
    final List<String> parts = <String>[
      event.address,
      event.aptSuiteOther,
      event.city,
      event.state,
      event.zipCode,
      event.country?.trim().isNotEmpty == true ? event.country : 'United States',
    ]
        .whereType<String>()
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '';
    }

    return parts.join(', ');
  }

  String _eventCacheKey(EventModel event, String query) {
    final String id = (event.eventID ?? '').trim();
    if (id.isNotEmpty) {
      return '$_coordinateCachePrefix:event:$id';
    }
    return '$_coordinateCachePrefix:query:${query.toLowerCase()}';
  }

  Future<LatLng?> _geocode(String query) async {
    try {
      final List<Location> locations = await locationFromAddress(query)
          .timeout(const Duration(seconds: 8));
      if (locations.isEmpty) {
        return null;
      }
      final Location location = locations.first;
      return LatLng(location.latitude, location.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<LatLng?> _readCachedPosition(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data = json.decode(raw) as Map<String, dynamic>;
      final Object? latitude = data['latitude'];
      final Object? longitude = data['longitude'];
      if (latitude is num && longitude is num) {
        return LatLng(latitude.toDouble(), longitude.toDouble());
      }
    } catch (_) {
      await prefs.remove(key);
    }

    return null;
  }

  Future<void> _writeCachedPosition(String key, LatLng position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      key,
      json.encode(<String, double>{
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    );
  }
}
