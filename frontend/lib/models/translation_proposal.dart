class TranslationProposal {
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

  TranslationProposal({
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
  });

  factory TranslationProposal.fromJson(Map<String, dynamic> json) {
    return TranslationProposal(
      id: json['id'] ?? '',
      scientificName: json['scientificName'] ?? '',
      darijaProposal: json['darijaProposal'] as String?,
      tamazightProposal: json['tamazightProposal'] as String?,
      contributorName: json['contributorName'] ?? '',
      contributorEmail: json['contributorEmail'] ?? '',
      region: json['region'] ?? '',
      notes: json['notes'] ?? '',
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      status: ProposalStatus.values.firstWhere(
        (e) => e.toString() == 'ProposalStatus.${json['status']}',
        orElse: () => ProposalStatus.pending,
      ),
    );
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
    };
  }

  TranslationProposal copyWith({
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
    return TranslationProposal(
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
