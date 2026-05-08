import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class ProfileService {
  final storage = FlutterSecureStorage();

  // Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await storage.read(key: Constants.tokenKey);
      print('DEBUG: Token found: ${token != null ? 'YES' : 'NO'}');
      print('DEBUG: API URL: ${Constants.apiUrl}/profile');

      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final url = '${Constants.apiUrl}/profile';
      print('DEBUG: Full URL: $url');
      print('DEBUG: Token length: ${token.length}');
      print('${token}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la récupération du profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? bio,
    String? location,
    String? profileImage,
  }) async {
    try {
      final token = await storage.read(key: Constants.tokenKey);
      if (token == null) {
        return {'success': false, 'message': 'Non authentifié'};
      }

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (location != null) body['location'] = location;
      if (profileImage != null) body['profileImage'] = profileImage;

      final response = await http.put(
        Uri.parse('${Constants.apiUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Erreur lors de la mise à jour du profil',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
}
