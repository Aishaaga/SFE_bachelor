import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../models/plant.dart';
import 'auth_service.dart';
import 'cache_service.dart'; // ← ADD THIS IMPORT
import 'package:http_parser/http_parser.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final CacheService _cacheService = CacheService(); // ← ADD THIS

  // Identifier une plante à partir d'une photo
  Future<Map<String, dynamic>> identifyPlant(File image) async {
    final startTime = DateTime.now();

    try {
      print('🔍 STEP 1: Getting token...');

      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      // 📸 STEP 1: Generate image hash for caching
      final imageBytes = await image.readAsBytes();
      final imageHash = CacheService.generateImageHash(imageBytes);

      // 📦 STEP 2: Check cache first
      final cachedResult = await _cacheService.getCachedPlant(imageHash);
      if (cachedResult != null) {
        print('✅ CACHE HIT! Returning cached result');
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        print('⏱️ Total time (cached): ${duration}ms');
        return cachedResult;
      }

      print('🔄 CACHE MISS! Calling PlantNet API');

      // 🚀 STEP 3: Prepare the request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/identify'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      // Auto-detect image type from file extension
      final fileExtension = image.path.split('.').last.toLowerCase();
      final contentType = fileExtension == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: contentType,
      ));

      // 🚀 STEP 4: Send request with timeout
      final response = await request.send().timeout(
        const Duration(seconds: 50),
        onTimeout: () {
          print(
              '❌ TIMEOUT at ${DateTime.now().difference(startTime).inMilliseconds}ms');
          throw Exception('PlantNet timeout after 50 seconds');
        },
      );
      print(
          '✅ Response received (${DateTime.now().difference(startTime).inMilliseconds}ms)');
      print('🔍 STEP 4: Reading response...');

      final responseData = await response.stream.bytesToString();
      print('📦 RAW RESPONSE: $responseData'); // ← ADD THIS LINE
      print('Response status code: ${response.statusCode}'); // ← ADD THIS

      final data = jsonDecode(responseData);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ VALIDATION: Check if plant data exists
        if (data['plant'] == null) {
          return {
            'success': false,
            'message': 'Plante non reconnue. Veuillez réessayer.',
          };
        }

        final plant = Plant.fromJson({
          ...data['plant'],
          'id': data['identificationId'],
          'confidence': data['plant']['confidence'],
        });

        // ✅ VALIDATION: Check if scientific name is valid
        if (plant.scientificName.isEmpty ||
            plant.scientificName == 'Nom scientifique inconnu') {
          return {
            'success': false,
            'message':
                'Cette plante n\'a pas pu être identifiée précisément. Essayez avec une photo plus nette.',
          };
        }

        // ✅ VALIDATION: Check confidence level
        if (plant.confidence < 0.3) {
          return {
            'success': false,
            'message':
                'Identification peu fiable (${(plant.confidence * 100).toInt()}%). Prenez une meilleure photo.',
          };
        }

        // 💾 STEP 5: Save to cache
        final result = {
          'success': true,
          'plant': plant,
          'identificationId': data['identificationId'],
        };

        await _cacheService.cachePlantIdentification(imageHash, result);

        final duration = DateTime.now().difference(startTime).inMilliseconds;
        print('✅ Plant identified in ${duration}ms');

        return result;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur d\'identification',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // 🚀 NEW: Identify plant with PARALLEL distribution fetch

  // 🔧 Helper: Fetch just the count (fast)
  Future<int> _fetchOccurrenceCount(String scientificName) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return 0;

      final response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/gbif/summary/${Uri.encodeComponent(scientificName)}'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['occurrenceCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error fetching count: $e');
      return 0;
    }
  }

  // 🔧 Helper: Fetch full occurrences (slower)
  Future<List<Map<String, dynamic>>> _fetchOccurrences(
      String scientificName) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(
            '${Constants.apiUrl}/gbif/occurrences/${Uri.encodeComponent(scientificName)}?limit=200'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['occurrences'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error fetching occurrences: $e');
      return [];
    }
  }

  // Récupérer l'historique des identifications
  Future<Map<String, dynamic>> getHistory() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/my-identifications'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final List<dynamic> identifications = data['identifications'];
        return {
          'success': true,
          'identifications': identifications,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur de récupération',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Supprimer une identification
  Future<Map<String, dynamic>> deleteIdentification(String id) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final response = await http.delete(
        Uri.parse('${Constants.apiUrl}/identifications/$id'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }
}
