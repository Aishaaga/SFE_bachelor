import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GBIFService {
  static const String baseUrl =
      'http://192.168.0.182:3000/api'; // Your backend URL
  static final _storage = FlutterSecureStorage();

  /// Get occurrences from YOUR backend (which calls GBIF)
  static Future<Map<String, dynamic>> getOccurrences(
      String scientificName) async {
    final url = '$baseUrl/gbif/summary/${Uri.encodeComponent(scientificName)}';
    print('📡 Calling URL: $url'); // DEBUG
    try {
      // Get auth token
      final token = await _storage.read(key: 'auth_token');
      const String baseUrl = 'http://192.168.0.182:3000/api';

      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      // Call YOUR backend, not GBIF directly
      final response = await http.get(
        Uri.parse(
            '$baseUrl/gbif/occurrences/${Uri.encodeComponent(scientificName)}?limit=100'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}'); // Debug
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Erreur: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Get just the count (faster)
  static Future<int> getOccurrenceCount(String scientificName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return 0;

      final response = await http.get(
        Uri.parse(
            '$baseUrl/gbif/summary/${Uri.encodeComponent(scientificName)}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['occurrenceCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
