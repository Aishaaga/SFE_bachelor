import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cachePrefix = 'plant_cache_';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Save plant identification to cache
  Future<void> cachePlantIdentification(
      String imageHash, Map<String, dynamic> result) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Don't cache failed results
      if (result['success'] != true) return;

      final cacheItem = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'result': result,
      };

      await prefs.setString('$_cachePrefix$imageHash', jsonEncode(cacheItem));
      print(
          '💾 Cached plant identification for hash: ${imageHash.substring(0, 20)}...');
    } catch (e) {
      print('Failed to cache: $e');
    }
  }

  // Get cached plant identification
  Future<Map<String, dynamic>?> getCachedPlant(String imageHash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_cachePrefix$imageHash');

      if (cached == null) return null;

      final data = jsonDecode(cached);
      final timestamp = data['timestamp'];
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if cache is still valid
      if (now - timestamp > _cacheDuration.inMilliseconds) {
        // Cache expired, delete it
        await prefs.remove('$_cachePrefix$imageHash');
        print('🗑️ Cache expired for hash: ${imageHash.substring(0, 20)}...');
        return null;
      }

      print('📦 Cache valid for hash: ${imageHash.substring(0, 20)}...');
      return Map<String, dynamic>.from(data['result']);
    } catch (e) {
      print('Failed to read cache: $e');
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
