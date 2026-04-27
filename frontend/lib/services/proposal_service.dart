import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/translation_suggestion.dart';
import '../services/auth_service.dart';

class ProposalService {
  static const String _baseUrl =
      'http://192.168.0.182:3000/api/translation-suggestions';

  static Future<Map<String, String>> _getHeaders() async {
    final authService = AuthService();
    final token = await authService.getToken();
    print('DEBUG: Token récupéré: $token');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('DEBUG: Headers avec auth: $headers');
    } else {
      print('DEBUG: Headers sans auth: $headers');
    }

    return headers;
  }

  static Future<List<TranslationSuggestion>> getAllProposals(
      {int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<dynamic> proposalsList = data['proposals'];
          return proposalsList
              .map((proposal) => TranslationSuggestion.fromJson(proposal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading proposals: $e');
      return [];
    }
  }

  static Future<void> saveProposal(TranslationSuggestion proposal) async {
    try {
      final headers = await _getHeaders();
      print('DEBUG: Envoi de la requête vers $_baseUrl');
      print('DEBUG: Corps de la requête: ${json.encode({
            'scientificName': proposal.scientificName,
            'darijaProposal': proposal.darijaProposal,
            'tamazightProposal': proposal.tamazightProposal,
            'contributorName': proposal.contributorName,
            'contributorEmail': proposal.contributorEmail,
            'contributorRegion': proposal.region,
            'notes': proposal.notes,
          })}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode({
          'scientificName': proposal.scientificName,
          'darijaProposal': proposal.darijaProposal,
          'tamazightProposal': proposal.tamazightProposal,
          'contributorName': proposal.contributorName,
          'contributorEmail': proposal.contributorEmail,
          'contributorRegion': proposal.region,
          'notes': proposal.notes,
        }),
      );

      print('DEBUG: Status code: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode != 201) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Erreur lors de la sauvegarde');
      }
    } catch (e) {
      print('Error saving proposal: $e');
      rethrow;
    }
  }

  static Future<List<TranslationSuggestion>> getProposalsByStatus(
      ProposalStatus status,
      {int page = 1,
      int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final statusString = status.toString().split('.').last;
      final response = await http.get(
        Uri.parse('$_baseUrl?status=$statusString&page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<dynamic> proposalsList = data['proposals'];
          return proposalsList
              .map((proposal) => TranslationSuggestion.fromJson(proposal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading proposals by status: $e');
      return [];
    }
  }

  static Future<List<TranslationSuggestion>> getProposalsByScientificName(
      String scientificName) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/scientific/${Uri.encodeComponent(scientificName)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<dynamic> proposalsList = data['proposals'];
          return proposalsList
              .map((proposal) => TranslationSuggestion.fromJson(proposal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error loading proposals by scientific name: $e');
      return [];
    }
  }

  static Future<void> updateProposalStatus(
      String proposalId, ProposalStatus newStatus,
      {String reviewNotes = ''}) async {
    try {
      final headers = await _getHeaders();
      final statusString = newStatus.toString().split('.').last;
      final response = await http.put(
        Uri.parse('$_baseUrl/$proposalId/status'),
        headers: headers,
        body: json.encode({
          'status': statusString,
          'reviewNotes': reviewNotes,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Erreur lors de la mise à jour');
      }
    } catch (e) {
      print('Error updating proposal status: $e');
      rethrow;
    }
  }

  static Future<void> deleteProposal(String proposalId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/$proposalId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      print('Error deleting proposal: $e');
      rethrow;
    }
  }

  static Future<Map<String, int>> getProposalStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/stats'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Map<String, int>.from(data['stats']);
        }
      }
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };
    } catch (e) {
      print('Error getting proposal stats: $e');
      return {
        'total': 0,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'needs_review': 0,
      };
    }
  }

  static Future<List<TranslationSuggestion>> searchProposals({
    String? q,
    String? scientificName,
    String? contributorName,
    String? contributorEmail,
    ProposalStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (q != null && q.isNotEmpty) queryParams['q'] = q;
      if (scientificName != null && scientificName.isNotEmpty)
        queryParams['scientificName'] = scientificName;
      if (contributorName != null && contributorName.isNotEmpty)
        queryParams['contributorName'] = contributorName;
      if (contributorEmail != null && contributorEmail.isNotEmpty)
        queryParams['contributorEmail'] = contributorEmail;
      if (status != null)
        queryParams['status'] = status.toString().split('.').last;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final uri =
          Uri.parse('$_baseUrl/search').replace(queryParameters: queryParams);

      final headers = await _getHeaders();
      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List<dynamic> proposalsList = data['proposals'];
          return proposalsList
              .map((proposal) => TranslationSuggestion.fromJson(proposal))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching proposals: $e');
      return [];
    }
  }
}
