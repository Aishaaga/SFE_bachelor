import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/translation_proposal.dart';
import '../services/proposal_service.dart';

class TranslationProposalScreen extends StatefulWidget {
  final Plant plant;

  const TranslationProposalScreen({
    super.key,
    required this.plant,
  });

  @override
  State<TranslationProposalScreen> createState() => _TranslationProposalScreenState();
}

class _TranslationProposalScreenState extends State<TranslationProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();
  final _contributorNameController = TextEditingController();
  final _contributorEmailController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _proposeDarija = true;
  bool _proposeTamazight = true;

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    _contributorNameController.dispose();
    _contributorEmailController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_proposeDarija && !_proposeTamazight) {
      _showErrorDialog('Veuillez proposer au moins une traduction (Darija ou Tamazight)');
      return;
    }

    if (_proposeDarija && _darijaController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez entrer une traduction en Darija');
      return;
    }

    if (_proposeTamazight && _tamazightController.text.trim().isEmpty) {
      _showErrorDialog('Veuillez entrer une traduction en Tamazight');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final proposal = TranslationProposal(
        id: _generateId(),
        scientificName: widget.plant.scientificName,
        darijaProposal: _proposeDarija ? _darijaController.text.trim() : null,
        tamazightProposal: _proposeTamazight ? _tamazightController.text.trim() : null,
        contributorName: _contributorNameController.text.trim(),
        contributorEmail: _contributorEmailController.text.trim(),
        region: _regionController.text.trim(),
        notes: _notesController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await ProposalService.saveProposal(proposal);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Erreur lors de la soumission: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _generateId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNum = random.nextInt(10000);
    return 'proposal_${timestamp}_$randomNum';
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Merci!'),
        content: const Text(
          'Votre proposition de traduction a été soumise avec succès.\n'
          'Elle sera examinée par notre équipe avant d\'être validée.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposer une traduction'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant info card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plant.scientificName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Famille: ${widget.plant.family}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Translation options
              const Text(
                'Quelles traductions souhaitez-vous proposer?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Darija (Marocain Arabe)'),
                subtitle: const Text('Traduction en arabe marocain'),
                value: _proposeDarija,
                onChanged: (value) {
                  setState(() {
                    _proposeDarija = value ?? true;
                  });
                },
                activeColor: Colors.green,
              ),
              CheckboxListTile(
                title: const Text('Tamazight'),
                subtitle: const Text('Traduction en berbère marocain'),
                value: _proposeTamazight,
                onChanged: (value) {
                  setState(() {
                    _proposeTamazight = value ?? true;
                  });
                },
                activeColor: Colors.green,
              ),
              const SizedBox(height: 24),

              // Darija translation field
              if (_proposeDarija) ...[
                TextFormField(
                  controller: _darijaController,
                  decoration: const InputDecoration(
                    labelText: 'Traduction en Darija',
                    hintText: 'Entrez le nom en arabe marocain',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(),
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Arabic'),
                  validator: (value) {
                    if (_proposeDarija && (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Tamazight translation field
              if (_proposeTamazight) ...[
                TextFormField(
                  controller: _tamazightController,
                  decoration: const InputDecoration(
                    labelText: 'Traduction en Tamazight',
                    hintText: 'Entrez le nom en tamazight',
                    prefixIcon: Icon(Icons.translate),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: 'Tifinagh'),
                  validator: (value) {
                    if (_proposeTamazight && (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Contributor information
              const Text(
                'Vos informations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contributorNameController,
                decoration: const InputDecoration(
                  labelText: 'Votre nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contributorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Votre email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Région (optionnel)',
                  hintText: 'Ex: Rabat, Marrakech, Souss...',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes supplémentaires (optionnel)',
                  hintText: 'Informations additionnelles sur votre traduction...',
                  prefixIcon: Icon(Icons.note_add),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitProposal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Soumettre la proposition',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
