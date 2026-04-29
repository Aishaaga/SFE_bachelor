import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('DEBUG: Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print('DEBUG: Location services are disabled');
      return false;
    }

    permission = await Geolocator.checkPermission();
    print('DEBUG: Current permission: $permission');
    if (permission == LocationPermission.denied) {
      print('DEBUG: Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      print('DEBUG: Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        print('DEBUG: Permission still denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('DEBUG: Permission denied forever');
      return false;
    }

    print('DEBUG: Permission granted');
    return true;
  }

  static Future<String?> getCurrentCity() async {
    try {
      print('DEBUG: Starting location detection...');

      // Check permissions first
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        print('DEBUG: No location permission');
        return null;
      }

      print('DEBUG: Getting current position...');
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('DEBUG: Got position: ${position.latitude}, ${position.longitude}');

      print('DEBUG: Getting placemarks...');
      // Get placemarks from coordinates
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      print('DEBUG: Found ${placemarks.length} placemarks');
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        print(
            'DEBUG: Placemark details: locality=${place.locality}, adminArea=${place.administrativeArea}, subAdminArea=${place.subAdministrativeArea}');

        // Try to get the city, fallback to administrative area
        final city = place.locality ??
            place.administrativeArea ??
            place.subAdministrativeArea;
        print('DEBUG: Detected city: $city');
        return city;
      }
    } catch (e) {
      print('DEBUG: Error getting location: $e');
    }
    print('DEBUG: No city detected');
    return null;
  }

  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
