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
    this.reviewNotes = '',
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
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : DateTime.now(),
      isValidated: json['isValidated'] ?? false,
    );
  }

  static ProposalStatus _parseStatus(String? status) {
    switch (status) {
      case 'approved':
        return ProposalStatus.approved;
      case 'rejected':
        return ProposalStatus.rejected;
      case 'needs_review':
        return ProposalStatus.needsReview;
      default:
        return ProposalStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientificName': scientificName,
      'darijaProposal': darijaProposal,
      'tamazightProposal': tamazightProposal,
      'contributorName': contributorName,
      'contributorEmail': contributorEmail,
      'region': region,
      'notes': notes,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'isValidated': isValidated,
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
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    bool? isValidated,
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
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      isValidated: isValidated ?? this.isValidated,
    );
  }
}

enum ProposalStatus {
  pending,
  approved,
  rejected,
  needsReview;

  @override
  String toString() {
    switch (this) {
      case ProposalStatus.pending:
        return 'pending';
      case ProposalStatus.approved:
        return 'approved';
      case ProposalStatus.rejected:
        return 'rejected';
      case ProposalStatus.needsReview:
        return 'needs_review';
    }
  }
}
