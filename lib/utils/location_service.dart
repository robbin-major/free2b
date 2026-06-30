import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppLocationLookupResult {
  const AppLocationLookupResult({
    required this.status,
    this.position,
    this.placemark,
    this.message,
  });

  final String status;
  final Position? position;
  final Placemark? placemark;
  final String? message;

  bool get hasCoordinates => position != null;
}

class AppLocationService {
  static Future<Position?> getCurrentPositionIfAllowed() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location unavailable: service disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Location permission before request: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Location permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location unavailable: permission $permission');
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 6));
      print(
        'Location coordinates: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (error) {
      print('Location unavailable: $error');
      return null;
    }
  }

  static Future<AppLocationLookupResult> getCurrentLocationIfAllowed() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location unavailable: service disabled');
        return const AppLocationLookupResult(
          status: 'service_disabled',
          message: 'Location services are disabled',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      print('Location permission before request: $permission');
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Location permission after request: $permission');
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print('Location unavailable: permission $permission');
        return AppLocationLookupResult(
          status: permission.name,
          message: 'Location permission is $permission',
        );
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 6));
      print(
        'Location coordinates: ${position.latitude}, ${position.longitude}',
      );

      try {
        final List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 6));
        final Placemark? placemark =
            placemarks.isNotEmpty ? placemarks.first : null;
        print(
          'Location placemark: '
          '${placemark?.postalCode}, ${placemark?.subLocality}, '
          '${placemark?.locality}, ${placemark?.administrativeArea}',
        );
        return AppLocationLookupResult(
          status: 'success',
          position: position,
          placemark: placemark,
        );
      } catch (error) {
        print('Location placemark unavailable: $error');
        return AppLocationLookupResult(
          status: 'coordinates_only',
          position: position,
          message: '$error',
        );
      }
    } catch (error) {
      print('Location lookup failed: $error');
      return AppLocationLookupResult(
        status: 'error',
        message: '$error',
      );
    }
  }

  static Future<Placemark?> getCurrentPlacemarkIfAllowed() async {
    final Position? position = await getCurrentPositionIfAllowed();
    if (position == null) {
      return null;
    }

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 6));
      return placemarks.isNotEmpty ? placemarks.first : null;
    } catch (error) {
      print('Location placemark unavailable: $error');
      return null;
    }
  }
}
