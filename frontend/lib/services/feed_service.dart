import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class FeedService {
  // Share a discovery to the community feed
  Future<Map<String, dynamic>> shareToFeed({
    String type = 'identification',
    required String plantId,
    required String plantName,
    required String scientificName,
    String? imageUrl,
    String? identificationId,
    String? suggestedDarija,
    String? suggestedTamazight,
    required bool isAnonymous,
    required Map<String, dynamic> location,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/feed/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode({
          'type': type,
          'plantId': plantId,
          'plantName': plantName,
          'scientificName': scientificName,
          'imageUrl': imageUrl,
          'identificationId': identificationId,
          'suggestedDarija': suggestedDarija,
          'suggestedTamazight': suggestedTamazight,
          'isAnonymous': isAnonymous,
          'location': location,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error sharing to feed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get all feed posts
  Future<Map<String, dynamic>> getFeedPosts({
    String? type,
    int page = 1,
    int limit = 20,
    String? locationLevel,
    String? city,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (type != null) queryParams['type'] = type;
      if (locationLevel != null) queryParams['locationLevel'] = locationLevel;
      if (city != null) queryParams['city'] = city;

      final uri = Uri.parse('${Constants.apiUrl}/feed')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'posts': data['data'],
          'pagination': data['pagination'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error fetching feed posts',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get a specific feed post
  Future<Map<String, dynamic>> getFeedPost(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/feed/$postId'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'post': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error fetching feed post',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Like a feed post (updated to use new API)
  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/feed-likes/posts/$postId/likes'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Like recorded successfully',
          'likes': data['likes'],
          'action': data['action'],
          'liked': data['liked'] ?? true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error liking post',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Flag a feed post
  Future<Map<String, dynamic>> flagPost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/feed/$postId/flag'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error flagging post',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Vote on a translation suggestion
  Future<Map<String, dynamic>> voteOnTranslation({
    required String postId,
    required String voteType, // 'upvote' or 'downvote'
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/translation-votes/posts/$postId/votes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode({
          'voteType': voteType,
          if (reason != null) 'reason': reason,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Vote recorded successfully',
          'voteCounts': data['voteCounts'],
          'action': data['action'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error voting on translation',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get vote counts for a translation suggestion
  Future<Map<String, dynamic>> getTranslationVotes(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/translation-votes/posts/$postId/votes'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'voteCounts': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error fetching vote counts',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get auth token
  Future<String> _getToken() async {
    // This should be imported from your auth service
    // For now, returning empty string - you'll need to integrate with your auth system
    const flutterSecureStorage = FlutterSecureStorage();
    return await flutterSecureStorage.read(key: Constants.tokenKey) ?? '';
  }
}
