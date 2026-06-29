import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AppLocationService {
  static Future<Position?> getCurrentPositionIfAllowed() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 6));
    } catch (error) {
      print('Location unavailable: $error');
      return null;
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
