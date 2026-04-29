import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/plant.dart';
import '../models/translation_suggestion.dart';
import '../services/proposal_service.dart';
import '../services/auth_service.dart';

class TranslationProposalScreen extends StatefulWidget {
  final Plant plant;

  const TranslationProposalScreen({
    super.key,
    required this.plant,
  });

  @override
  State<TranslationProposalScreen> createState() =>
      _TranslationProposalScreenState();
}

class _TranslationProposalScreenState extends State<TranslationProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _darijaController = TextEditingController();
  final _tamazightController = TextEditingController();
  final _regionController = TextEditingController();
  final _notesController = TextEditingController();
  final _authService = AuthService();

  bool _isSubmitting = false;
  bool _proposeDarija = true;
  bool _proposeTamazight = true;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _darijaController.dispose();
    _tamazightController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final email = await _authService.getCurrentUserEmail();
      if (email != null) {
        setState(() {
          _userEmail = email;
          // Extract name from email (before @ symbol) or use full email as name
          _userName = email.split('@')[0];
        });
      }
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  Future<void> _submitProposal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_proposeDarija && !_proposeTamazight) {
      _showErrorDialog(
          'Veuillez proposer au moins une traduction (Darija ou Tamazight)');
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

    // Vérifier si l'utilisateur est connecté
    final authService = AuthService();
    final isLoggedIn = await authService.isLoggedIn();
    if (!isLoggedIn) {
      _showErrorDialog(
          'Vous devez être connecté pour soumettre une traduction');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final suggestion = TranslationSuggestion(
        id: _generateId(),
        scientificName: widget.plant.scientificName,
        darijaProposal: _proposeDarija ? _darijaController.text.trim() : null,
        tamazightProposal:
            _proposeTamazight ? _tamazightController.text.trim() : null,
        contributorName: _userName ?? 'Anonymous',
        contributorEmail: _userEmail ?? 'anonymous@example.com',
        region: _regionController.text.trim(),
        notes: _notesController.text.trim(),
        submittedAt: DateTime.now(),
      );

      await ProposalService.saveProposal(suggestion);

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
                    if (_proposeDarija &&
                        (value == null || value.trim().isEmpty)) {
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
                    if (_proposeTamazight &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Contributor information (auto-detected)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Soumis par: ${_userName ?? 'Chargement...'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _userEmail ?? 'Chargement...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  hintText:
                      'Informations additionnelles sur votre traduction...',
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
