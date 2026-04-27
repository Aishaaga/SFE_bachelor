class TranslationSuggestion {
  final String id;
  final String scientificName;
  final String? darijaProposal;
  final String? tamazightProposal;
  final String contributorName;
  final String contributorEmail;
  final String region;
  final String notes;
  final DateTime submittedAt;
  final ProposalStatus status;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final bool isValidated;

  TranslationSuggestion({
    required this.id,
    required this.scientificName,
    this.darijaProposal,
    this.tamazightProposal,
    required this.contributorName,
    required this.contributorEmail,
    this.region = '',
    this.notes = '',
    required this.submittedAt,
    this.status = ProposalStatus.pending,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.isValidated = false,
  });

  factory TranslationSuggestion.fromJson(Map<String, dynamic> json) {
    return TranslationSuggestion(
      id: json['_id'] ?? json['id'] ?? '',
      scientificName: json['scientificName'] ?? '',
      darijaProposal: json['darijaProposal'] as String?,
      tamazightProposal: json['tamazightProposal'] as String?,
      contributorName: json['contributorName'] ?? '',
      contributorEmail: json['contributorEmail'] ?? '',
      region: json['contributorRegion'] ?? json['region'] ?? '',
      notes: json['notes'] ?? '',
      submittedAt: DateTime.parse(
          json['submittedAt'] ?? DateTime.now().toIso8601String()),
      status: _parseStatus(json['status']),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      reviewedBy: json['reviewedBy']?.toString(),
      reviewNotes: json['reviewNotes'] as String?,
      isValidated: json['isValidated'] ?? false,
    );
  }

  static ProposalStatus _parseStatus(String? statusString) {
    if (statusString == null) return ProposalStatus.pending;

    switch (statusString.toLowerCase()) {
      case 'pending':
        return ProposalStatus.pending;
      case 'approved':
        return ProposalStatus.approved;
      case 'rejected':
        return ProposalStatus.rejected;
      case 'needs_review':
        return ProposalStatus.needs_review;
      default:
        return ProposalStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'scientificName': scientificName,
      'darijaProposal': darijaProposal,
      'tamazightProposal': tamazightProposal,
      'contributorName': contributorName,
      'contributorEmail': contributorEmail,
      'contributorRegion': region,
      'notes': notes,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }

  TranslationSuggestion copyWith({
    String? id,
    String? scientificName,
    String? darijaProposal,
    String? tamazightProposal,
    String? contributorName,
    String? contributorEmail,
    String? region,
    String? notes,
    DateTime? submittedAt,
    ProposalStatus? status,
  }) {
    return TranslationSuggestion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      darijaProposal: darijaProposal ?? this.darijaProposal,
      tamazightProposal: tamazightProposal ?? this.tamazightProposal,
      contributorName: contributorName ?? this.contributorName,
      contributorEmail: contributorEmail ?? this.contributorEmail,
      region: region ?? this.region,
      notes: notes ?? this.notes,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
    );
  }

  bool get hasValidProposal {
    return (darijaProposal != null && darijaProposal!.isNotEmpty) ||
        (tamazightProposal != null && tamazightProposal!.isNotEmpty);
  }
}

enum ProposalStatus {
  pending,
  approved,
  rejected,
  needs_review,
}
