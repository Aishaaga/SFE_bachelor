import 'package:flutter/material.dart';
import '../models/translation_suggestion.dart';
import '../services/proposal_service.dart';

class AdminProposalsScreen extends StatefulWidget {
  const AdminProposalsScreen({super.key});

  @override
  State<AdminProposalsScreen> createState() => _AdminProposalsScreenState();
}

class _AdminProposalsScreenState extends State<AdminProposalsScreen> {
  List<TranslationSuggestion> _proposals = [];
  bool _isLoading = true;
  ProposalStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final proposals = _filterStatus != null
          ? await ProposalService.getProposalsByStatus(_filterStatus!)
          : await ProposalService.getAllProposals();

      setState(() {
        _proposals = proposals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _updateProposalStatus(
      String proposalId, ProposalStatus newStatus) async {
    try {
      await ProposalService.updateProposalStatus(proposalId, newStatus);
      _loadProposals(); // Reload to show updated status

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour: ${newStatus.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _deleteProposal(String proposalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            const Text('Voulez-vous vraiment supprimer cette proposition?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ProposalService.deleteProposal(proposalId);
        _loadProposals();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proposition supprimée')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration des propositions'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<ProposalStatus>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _filterStatus =
                    status == ProposalStatus.values.first ? null : status;
              });
              _loadProposals();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ProposalStatus.pending,
                child: Text('Toutes'),
              ),
              ...ProposalStatus.values.map((status) => PopupMenuItem(
                    value: status,
                    child: Text(_getStatusText(status)),
                  )),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _proposals.isEmpty
              ? const Center(
                  child: Text('Aucune proposition trouvée'),
                )
              : ListView.builder(
                  itemCount: _proposals.length,
                  itemBuilder: (context, index) {
                    final proposal = _proposals[index];
                    return ProposalCard(
                      proposal: proposal,
                      onStatusChanged: (newStatus) =>
                          _updateProposalStatus(proposal.id, newStatus),
                      onDelete: () => _deleteProposal(proposal.id),
                    );
                  },
                ),
    );
  }

  String _getStatusText(ProposalStatus status) {
    switch (status) {
      case ProposalStatus.pending:
        return 'En attente';
      case ProposalStatus.approved:
        return 'Approuvée';
      case ProposalStatus.rejected:
        return 'Rejetée';
      case ProposalStatus.needsReview:
        return 'Nécessite une review';
    }
  }
}

class ProposalCard extends StatelessWidget {
  final TranslationSuggestion proposal;
  final Function(ProposalStatus) onStatusChanged;
  final VoidCallback onDelete;

  const ProposalCard({
    super.key,
    required this.proposal,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with scientific name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    proposal.scientificName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                _buildStatusChip(proposal.status),
              ],
            ),
            const SizedBox(height: 12),

            // Proposed translations
            if (proposal.darijaProposal != null) ...[
              _buildTranslationRow(
                  'Darija:', proposal.darijaProposal!, Colors.green),
              const SizedBox(height: 8),
            ],
            if (proposal.tamazightProposal != null) ...[
              _buildTranslationRow(
                  'Tamazight:', proposal.tamazightProposal!, Colors.blue),
              const SizedBox(height: 12),
            ],

            // Contributor info
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(
                Icons.person, 'Contributeur:', proposal.contributorName),
            _buildInfoRow(Icons.email, 'Email:', proposal.contributorEmail),
            if (proposal.region.isNotEmpty)
              _buildInfoRow(Icons.location_on, 'Région:', proposal.region),
            _buildInfoRow(Icons.calendar_today, 'Date:',
                '${proposal.submittedAt.day}/${proposal.submittedAt.month}/${proposal.submittedAt.year}'),

            if (proposal.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${proposal.notes}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: 16),
            Row(
              children: [
                if (proposal.status == ProposalStatus.pending) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChanged(ProposalStatus.approved),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approuver'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChanged(ProposalStatus.rejected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Rejeter'),
                    ),
                  ),
                ] else if (proposal.status == ProposalStatus.rejected) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onStatusChanged(ProposalStatus.pending),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Réexaminer'),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProposalStatus status) {
    Color color;
    String text;

    switch (status) {
      case ProposalStatus.pending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case ProposalStatus.approved:
        color = Colors.green;
        text = 'Approuvée';
        break;
      case ProposalStatus.rejected:
        color = Colors.red;
        text = 'Rejetée';
        break;
      case ProposalStatus.needsReview:
        color = Colors.purple;
        text = 'À revoir';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildTranslationRow(String label, String translation, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            translation,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label $value',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
