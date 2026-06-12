import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../utils/constants.dart';

class GBIFService {
  static const String baseUrl = Constants.apiUrl;
  static final _storage = FlutterSecureStorage();
  int limit = 200;
  static final Map<String, _CachedGBIFData> _cache = {};

  // Static cache shared across all calls

  static Future<Map<String, dynamic>> getOccurrences(
    String scientificName, {
    int limit = 100,
    String? country,
    int? year,
    bool useCache = true,
  }) async {
    // Create cache key from parameters
    final cacheKey = '$scientificName|$limit|$country|$year';

    // Check cache (if enabled)
    if (useCache && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (cached.isValid()) {
        print('📦 GBIF cache hit for: $scientificName');
        return cached.data;
      } else {
        // Remove expired cache
        _cache.remove(cacheKey);
      }
    }

    print('🌍 GBIF cache miss for: $scientificName');
    final startTime = DateTime.now();

    // Quick connectivity test
    try {
      print('⏰ Testing connectivity...');
      await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));
      print('⏰ Connectivity test OK');
    } catch (e) {
      print('⚠️ Connectivity test failed: $e');
      return {'success': false, 'message': 'Problème de connexion au serveur'};
    }

    try {
      final _authService = AuthService();
      print('⏰ Getting auth token...');
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }
      print(
          '⏰ Auth token received in ${DateTime.now().difference(startTime).inMilliseconds}ms');

      var url =
          '$baseUrl/gbif/occurrences/${Uri.encodeComponent(scientificName)}?limit=$limit';
      if (country != null && country != 'all') {
        url += '&country=$country';
      }
      if (year != null && year != 0) {
        url += '&year=$year';
      }

      print('⏰ Making HTTP request to: $url');
      final requestStart = DateTime.now();
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      print(
          '⏰ HTTP response received in ${DateTime.now().difference(requestStart).inMilliseconds}ms');

      if (response.statusCode == 401) {
        await AuthService.handle401Error();
        return {'success': false, 'message': 'Session expirée'};
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save to cache (valid for 1 hour)
        _cache[cacheKey] = _CachedGBIFData(
          data: data,
          timestamp: DateTime.now(),
        );

        return data;
      } else {
        return {'success': false, 'message': 'Erreur: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error fetching occurrences: $e');

      // Handle timeout specifically
      if (e.toString().contains('TimeoutException')) {
        // Try to return stale cache if available
        if (_cache.containsKey(cacheKey)) {
          final staleCache = _cache[cacheKey]!;
          print('⚠️ Using stale cache for: $scientificName');
          return {
            ...staleCache.data,
            'success': true,
            'usingStaleCache': true,
            'message': 'Données mises en cache (service GBIF lent)'
          };
        }
        return {
          'success': false,
          'message':
              'Le service GBIF est lent. Essayez de vous rapprocher du routeur WiFi ou utilisez un émulateur.'
        };
      }

      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  static Future<int> getOccurrenceCount(String scientificName) async {
    final cacheKey = 'count|$scientificName';

    // Check cache
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (cached.isValid()) {
        print('📦 GBIF count cache hit for: $scientificName');
        return cached.data['occurrenceCount'] ?? 0;
      }
    }

    try {
      final _authService = AuthService();
      final token = await _authService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse(
            '$baseUrl/gbif/summary/${Uri.encodeComponent(scientificName)}'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 401) {
        await AuthService.handle401Error();
        return 0;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final count = data['occurrenceCount'] ?? 0;

        // Save to cache
        _cache[cacheKey] = _CachedGBIFData(
          data: {'occurrenceCount': count},
          timestamp: DateTime.now(),
        );

        return count;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Clear cache (useful for refresh)
  static void clearCache() {
    _cache.clear();
    print('🗑️ GBIF cache cleared');
  }
}

class _CachedGBIFData {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _CachedGBIFData({
    required this.data,
    required this.timestamp,
  });

  bool isValid() {
    // Cache valid for 6 hours (extended for better fallback)
    return DateTime.now().difference(timestamp).inHours < 6;
  }
}
