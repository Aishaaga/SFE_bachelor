import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import '../models/plant.dart';
import 'auth_service.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final AuthService _authService = AuthService();

  // Identifier une plante à partir d'une photo
  Future<Map<String, dynamic>> identifyPlant(File image) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/identify'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'), // FORCE the correct MIME type
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
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

        // ✅ VALIDATION: Check confidence level (optional)
        if (plant.confidence < 0.5) {
          return {
            'success': false,
            'message':
                'Identification peu fiable (${(plant.confidence * 100).toInt()}%). Prenez une meilleure photo.',
          };
        }

        return {
          'success': true,
          'plant': plant,
          'identificationId': data['identificationId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur d\'identification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
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
      );

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
      );

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
