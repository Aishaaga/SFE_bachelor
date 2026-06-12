import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import 'auth_service.dart';
import '../utils/constants.dart';

class NotificationService {
  final AuthService _authService = AuthService();

  Future<List<AppNotification>> getNotifications({int limit = 20}) async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/notifications?limit=$limit'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await AuthService.handle401Error();
      return [];
    }

    final data = jsonDecode(response.body);

    if (data['success']) {
      return (data['notifications'] as List)
          .map((n) => AppNotification.fromJson(n))
          .toList();
    }
    return [];
  }

  Future<int> getUnreadCount() async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${Constants.apiUrl}/notifications?unreadOnly=true&limit=1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await AuthService.handle401Error();
      return 0;
    }

    final data = jsonDecode(response.body);
    return data['unreadCount'] ?? 0;
  }

  Future<void> markAsRead(String notificationId) async {
    final token = await _authService.getToken();

    final response = await http.put(
      Uri.parse('${Constants.apiUrl}/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await AuthService.handle401Error();
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _authService.getToken();

    final response = await http.put(
      Uri.parse('${Constants.apiUrl}/notifications/read-all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await AuthService.handle401Error();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final token = await _authService.getToken();

    final response = await http.delete(
      Uri.parse('${Constants.apiUrl}/notifications/$notificationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      await AuthService.handle401Error();
    }
  }
}
