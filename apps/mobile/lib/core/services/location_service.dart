// core/services/location_service.dart
import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// Thin wrapper for location + distance math used by the map screens.
class LocationService {
  LocationService._();

  /// Requests runtime permission and returns the current device position,
  /// or null when the user denies / location is off / a fix times out.
  /// Never blocks forever: the GPS fix is capped at 8 seconds.
  static Future<Position?> getCurrentPosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      var current = permission;

      if (current == LocationPermission.denied) {
        current = await Geolocator.requestPermission();
      }

      if (current == LocationPermission.denied ||
          current == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 8),
        ),
      ).timeout(const Duration(seconds: 8));
    } on Exception {
      return null;
    }
  }

  /// True when the app has been granted location permission.
  static Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Requests permission when it's still undecided.
  /// Safe to call at app start; never throws.
  static Future<void> requestPermissionIfNeeded() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }
    } catch (_) {
      // Location services unavailable — ignore on launch.
    }
  }

  /// Great-circle distance between two points in kilometers.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0; // Earth radius in km
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Naive travel time estimate (km/h) for a short city trip with traffic.
  static Duration estimateDriveTime(double km) {
    final minutes = (km / 40 * 60).round().clamp(1, 90);
    return Duration(minutes: minutes);
  }

  static double _rad(double deg) => deg * math.pi / 180;
}