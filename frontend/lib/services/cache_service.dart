import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/plant.dart';

class CacheService {
  static const String _cachePrefix = 'plant_cache_';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Save plant identification to cache
  Future<void> cachePlantIdentification(
      String imageHash, Map<String, dynamic> result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      print('💾 [CACHE] Attempting to save...');
      print('   Hash: $imageHash');
      print('   Result success: ${result['success']}');
      // Don't cache failed results
      if (result['success'] != true) {
        print('❌ [CACHE] Not caching - result not successful');
        return;
      }

      // 🔧 FIX: Convert Plant object to JSON Map
      final plant = result['plant'];
      final plantJson = {
        'name': plant.name,
        'scientificName': plant.scientificName,
        'confidence': plant.confidence,
        'family': plant.family,
        'id': plant.id,
      };

      // Create a serializable result
      final serializableResult = {
        'success': result['success'],
        'plant': plantJson, // ← Now it's a Map, not a Plant object
        'identificationId': result['identificationId'],
      };

      final cacheItem = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'result': serializableResult,
      };

      await prefs.setString('$_cachePrefix$imageHash', jsonEncode(cacheItem));
      print('✅ [CACHE] Saved successfully!');

      // Verify
      final saved = prefs.getString('$_cachePrefix$imageHash');
      print(
          '   Verification: ${saved != null ? "Saved (${saved.length} bytes)" : "NOT SAVED!"}');
    } catch (e) {
      print('❌ [CACHE] Failed to save: $e');
    }
  }

  // Get cached plant identification
  Future<Map<String, dynamic>?> getCachedPlant(String imageHash) async {
    try {
      print('🔍 [CACHE] Looking for hash: $imageHash');

      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_cachePrefix$imageHash');

      if (cached == null) {
        print('❌ [CACHE] Not found');

        return null;
      }
      print('✅ [CACHE] Found cached entry');

      final data = jsonDecode(cached);
      final timestamp = data['timestamp'];
      final now = DateTime.now().millisecondsSinceEpoch;
      final ageHours = (now - timestamp) / (1000 * 60 * 60);
      print('   Cache age: ${ageHours.toStringAsFixed(1)} hours');

      // Check if cache is still valid
      if (now - timestamp > _cacheDuration.inMilliseconds) {
        // Cache expired, delete it
        print('🗑️ [CACHE] Expired');

        await prefs.remove('$_cachePrefix$imageHash');
        return null;
      }

      // 🔧 FIX: Convert JSON back to Plant object
      final result = data['result'];
      final plantJson = result['plant'];

      // Recreate Plant object from JSON
      final plant = Plant(
        name: plantJson['name'],
        scientificName: plantJson['scientificName'],
        confidence: plantJson['confidence'],
        family: plantJson['family'],
        id: plantJson['id'],
      );

      final restoredResult = {
        'success': result['success'],
        'plant': plant, // ← Now it's a Plant object again
        'identificationId': result['identificationId'],
      };

      print('✅ [CACHE] Valid cache hit! Plant: ${plant.name}');
      return restoredResult;
    } catch (e) {
      print('❌ [CACHE] Error reading: $e');
      return null;
    }
  }

  // Generate simple hash from image bytes
  static String generateImageHash(List<int> bytes) {
    // Simple but effective hash
    final hash = bytes.length.toString() + '_' + bytes.take(100).join();
    // Add a simple checksum
    final checksum = bytes.fold(0, (sum, byte) => sum + byte) % 10000;
    return '${hash}_$checksum';
  }

  // Clear all cache (useful for debugging)
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
      print('🗑️ Cleared all cache (${keys.length} items)');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }

  // Get cache size (number of cached items)
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs
          .getKeys()
          .where((key) => key.startsWith(_cachePrefix))
          .length;
    } catch (e) {
      return 0;
    }
  }
}
