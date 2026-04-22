import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_proposal.dart';

class ProposalService {
  static const String _proposalsKey = 'translation_proposals';

  static Future<List<TranslationProposal>> getAllProposals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final proposalsJson = prefs.getString(_proposalsKey) ?? '[]';
      
      final List<dynamic> proposalsList = json.decode(proposalsJson);
      return proposalsList
          .map((proposal) => TranslationProposal.fromJson(proposal))
          .toList();
    } catch (e) {
      print('Error loading proposals: $e');
      return [];
    }
  }

  static Future<void> saveProposal(TranslationProposal proposal) async {
    try {
      final proposals = await getAllProposals();
      proposals.add(proposal);
      
      final prefs = await SharedPreferences.getInstance();
      final proposalsJson = json.encode(
        proposals.map((p) => p.toJson()).toList(),
      );
      
      await prefs.setString(_proposalsKey, proposalsJson);
    } catch (e) {
      print('Error saving proposal: $e');
      rethrow;
    }
  }

  static Future<List<TranslationProposal>> getProposalsByStatus(ProposalStatus status) async {
    final proposals = await getAllProposals();
    return proposals.where((proposal) => proposal.status == status).toList();
  }

  static Future<List<TranslationProposal>> getProposalsByScientificName(String scientificName) async {
    final proposals = await getAllProposals();
    return proposals
        .where((proposal) => proposal.scientificName == scientificName)
        .toList();
  }

  static Future<void> updateProposalStatus(String proposalId, ProposalStatus newStatus) async {
    try {
      final proposals = await getAllProposals();
      final index = proposals.indexWhere((p) => p.id == proposalId);
      
      if (index != -1) {
        proposals[index] = proposals[index].copyWith(status: newStatus);
        
        final prefs = await SharedPreferences.getInstance();
        final proposalsJson = json.encode(
          proposals.map((p) => p.toJson()).toList(),
        );
        
        await prefs.setString(_proposalsKey, proposalsJson);
      }
    } catch (e) {
      print('Error updating proposal status: $e');
      rethrow;
    }
  }

  static Future<void> deleteProposal(String proposalId) async {
    try {
      final proposals = await getAllProposals();
      proposals.removeWhere((p) => p.id == proposalId);
      
      final prefs = await SharedPreferences.getInstance();
      final proposalsJson = json.encode(
        proposals.map((p) => p.toJson()).toList(),
      );
      
      await prefs.setString(_proposalsKey, proposalsJson);
    } catch (e) {
      print('Error deleting proposal: $e');
      rethrow;
    }
  }

  static Future<Map<String, int>> getProposalStats() async {
    final proposals = await getAllProposals();
    
    final stats = <String, int>{
      'total': proposals.length,
      'pending': proposals.where((p) => p.status == ProposalStatus.pending).length,
      'approved': proposals.where((p) => p.status == ProposalStatus.approved).length,
      'rejected': proposals.where((p) => p.status == ProposalStatus.rejected).length,
      'needs_review': proposals.where((p) => p.status == ProposalStatus.needs_review).length,
    };
    
    return stats;
  }

  static Future<void> clearAllProposals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_proposalsKey);
    } catch (e) {
      print('Error clearing proposals: $e');
      rethrow;
    }
  }

  static Future<List<TranslationProposal>> searchProposals({
    String? scientificName,
    String? contributorName,
    ProposalStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final proposals = await getAllProposals();
    
    return proposals.where((proposal) {
      if (scientificName != null && scientificName.isNotEmpty) {
        if (!proposal.scientificName.toLowerCase().contains(scientificName.toLowerCase())) {
          return false;
        }
      }
      
      if (contributorName != null && contributorName.isNotEmpty) {
        if (!proposal.contributorName.toLowerCase().contains(contributorName.toLowerCase())) {
          return false;
        }
      }
      
      if (status != null) {
        if (proposal.status != status) {
          return false;
        }
      }
      
      if (startDate != null) {
        if (proposal.submittedAt.isBefore(startDate)) {
          return false;
        }
      }
      
      if (endDate != null) {
        if (proposal.submittedAt.isAfter(endDate)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }
}
