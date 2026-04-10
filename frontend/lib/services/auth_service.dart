import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';
import '../models/user.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  // Inscription
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        // Sauvegarder le token
        await storage.write(key: Constants.tokenKey, value: data['token']);
        await storage.write(key: Constants.userEmailKey, value: email);

        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // Connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Sauvegarder le token
        await storage.write(key: Constants.tokenKey, value: data['token']);
        await storage.write(key: Constants.userEmailKey, value: email);

        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await storage.delete(key: Constants.tokenKey);
    await storage.delete(key: Constants.userEmailKey);
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: Constants.tokenKey);
    return token != null;
  }

  // Récupérer le token
  Future<String?> getToken() async {
    return await storage.read(key: Constants.tokenKey);
  }
}
