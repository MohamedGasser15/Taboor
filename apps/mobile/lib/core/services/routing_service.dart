import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

class OSRMRouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final Duration duration;

  OSRMRouteResult({
    required this.points,
    required this.distanceKm,
    required this.duration,
  });
}

class RoutingService {
  static Future<OSRMRouteResult?> getRoute({
    required LatLng start,
    required LatLng end,
  }) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes.first;
          final geometry = route['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          final points = coordinates.map((coord) {
            final lng = (coord[0] as num).toDouble();
            final lat = (coord[1] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          final distanceMeters = (route['distance'] as num).toDouble();
          final durationSeconds = (route['duration'] as num).toDouble();

          return OSRMRouteResult(
            points: points,
            distanceKm: distanceMeters / 1000.0,
            duration: Duration(seconds: durationSeconds.round()),
          );
        }
      }
    } catch (_) {
      // Fail silently
    }
    return null;
  }
}
